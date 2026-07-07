#!/usr/bin/env bash
###############################################################################
# Bedrock Bootstrap for Cowork 3P Mode
#
# Distribution: host this file anywhere clients can open it as plain text
# (e.g. a GitHub raw link). The client selects ALL the text, copies it, and
# pastes it directly into AWS CloudShell. It also works via file upload
# (bash bedrock-bootstrap.sh) or curl | bash.
#
# Paste-safety: everything is wrapped in main(), which only runs on the last
# line — so the interactive prompts work even when the whole script arrives
# through the terminal. Prompts read from /dev/tty for the same reason.
#
# What it does, in order:
#   1. Submits the one-time Anthropic use-case form (PutUseCaseForModelAccess)
#   2. §203 StGB hardening: ensures Bedrock model invocation logging is OFF
#      in ALL EU regions (prompt/response content must never be logged)
#   3. Creates a least-privilege IAM user (invoke-only, Anthropic models only)
#   4. Generates a long-term Bedrock API key (bearer token, "ABSK...")
#   5. Warm-up invocation (activates the automatic Marketplace subscription)
#   6. Prints a JSON block ready to paste into the Cowork 3P Bedrock config
#
# Region: eu-central-1 (Frankfurt). Models use the EU geo cross-region
# inference profile (eu.anthropic.*) — requests are processed only within
# EU regions.
#
# Idempotent: safe to re-run. Re-running rotates the API key if two exist.
#
# Full removal (deletes API keys, policy, and the IAM user):
#   bash bedrock-bootstrap.sh teardown
###############################################################################
set -euo pipefail

SCRIPT_VERSION="0.1.0"   # bump on every published change; must match the git tag

# ── Helpers ──────────────────────────────────────────────────────────────────
say()  { printf '\n\033[1;34m▸ %s\033[0m\n' "$*"; }
ok()   { printf '\033[1;32m  ✓ %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m  ! %s\033[0m\n' "$*"; }
die()  { printf '\033[1;31m  ✗ %s\033[0m\n' "$*" >&2; exit 1; }

# Clean up a pasted URL: extract from markdown links like [text](url),
# strip whitespace/stray brackets/quotes, ensure an https:// prefix.
sanitize_url() {
  local u="$1" md_re='\((https?://[^)]+)\)'
  if [[ "$u" =~ $md_re ]]; then u="${BASH_REMATCH[1]}"; fi
  u="${u//[$'\t\r\n ']/}"
  u="${u#[\[\"\']}" ; u="${u%[]\"\']}"
  [[ "$u" =~ ^https?:// ]] || u="https://${u}"
  printf '%s' "$u"
}

# Trim whitespace and strip stray quotes from free-text input.
sanitize_text() {
  local t="$1"
  t="${t#"${t%%[![:space:]]*}"}" ; t="${t%"${t##*[![:space:]]}"}"
  t="${t//\"/}"
  printf '%s' "$t"
}

main() {
  # ── Configuration ──────────────────────────────────────────────────────────
  local REGION="${REGION:-eu-central-1}"
  local IAM_USER="${IAM_USER:-cowork-bedrock}"
  local POLICY_NAME="ClaudeBedrockInvoke"
  local KEY_AGE_DAYS="${KEY_AGE_DAYS:-30}"

  # EU geo cross-region inference profile (processed within EU regions only).
  # Used for the warm-up invocation and as the recommended model in Cowork.
  local MODEL_ID="${MODEL_ID:-eu.anthropic.claude-opus-4-6-v1}"

  # EU regions swept for the §203 logging check (invocation logging is
  # regional; the geo profile can route to any of these)
  local EU_REGIONS=(eu-central-1 eu-central-2 eu-west-1 eu-west-2 eu-west-3 eu-north-1 eu-south-1 eu-south-2)

  local COMPANY_NAME="${COMPANY_NAME:-}"
  local COMPANY_URL="${COMPANY_URL:-}"
  local USE_CASE_TEXT="${USE_CASE_TEXT:-Internal legal knowledge work: document review, drafting, and research by professional staff.}"

  command -v aws >/dev/null || die "AWS CLI not found. Run this in AWS CloudShell."

  # ── Teardown mode: bash bedrock-bootstrap.sh teardown ──────────────────────
  # Removes everything this script created (API keys, policy, IAM user).
  if [[ "${1:-}" == "teardown" ]]; then
    say "Teardown — removing everything this script created"
    local cred_id
    for cred_id in $(aws iam list-service-specific-credentials \
        --user-name "$IAM_USER" --service-name bedrock.amazonaws.com \
        --query 'ServiceSpecificCredentials[].ServiceSpecificCredentialId' \
        --output text 2>/dev/null || true); do
      aws iam delete-service-specific-credential \
        --user-name "$IAM_USER" --service-specific-credential-id "$cred_id" \
        && ok "Deleted API key ${cred_id}"
    done
    aws iam delete-user-policy --user-name "$IAM_USER" \
      --policy-name "$POLICY_NAME" 2>/dev/null \
      && ok "Deleted policy '${POLICY_NAME}'" || warn "No policy to delete"
    aws iam delete-user --user-name "$IAM_USER" 2>/dev/null \
      && ok "Deleted IAM user '${IAM_USER}'" || warn "No user to delete"
    rm -rf "$HOME/cowork-3p-config" && ok "Removed saved config from CloudShell"
    echo
    echo "  Note: the Anthropic use-case form is account-level and remains on"
    echo "  file (it cannot be withdrawn via API) — re-running the setup will"
    echo "  simply skip that step. Any Cowork app still holding the old bearer"
    echo "  token has lost access as of now."
    return 0
  fi

  say "Step 0/6 — Checking identity (Bedrock Setup v${SCRIPT_VERSION})"
  local ACCOUNT_ID
  ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text) \
    || die "No valid AWS credentials in this session."
  ok "Account: ${ACCOUNT_ID}  Region: ${REGION} (Frankfurt)"

  # ── 1. Anthropic first-time-use form ───────────────────────────────────────
  say "Step 1/6 — Anthropic use-case form"
  if aws bedrock get-use-case-for-model-access --region "$REGION" >/dev/null 2>&1; then
    ok "Use-case form already on file for this account/org"
  else
    if [[ -z "$COMPANY_NAME" || -z "$COMPANY_URL" ]]; then
      echo "  The one-time Anthropic use-case form has not been submitted yet."
      read -rp "  Company name: " COMPANY_NAME </dev/tty
      COMPANY_NAME=$(sanitize_text "$COMPANY_NAME")
      while :; do
        read -rp "  Company website (e.g. https://www.yourfirm.de): " COMPANY_URL </dev/tty
        COMPANY_URL=$(sanitize_url "$COMPANY_URL")
        [[ "$COMPANY_URL" =~ ^https?://[A-Za-z0-9.-]+\.[A-Za-z]{2,}(/.*)?$ ]] && break
        warn "That doesn't look like a website address — please type it like: https://www.yourfirm.de"
      done
      echo "  Using: ${COMPANY_NAME} — ${COMPANY_URL}"
    fi
    # Schema per AWS API reference (all six fields required):
    #   intendedUsers: "0" = internal employees, "1" = external users
    local FORM_JSON
    if command -v jq >/dev/null; then
      FORM_JSON=$(jq -n \
        --arg cn "$COMPANY_NAME" \
        --arg cw "$COMPANY_URL" \
        --arg uc "$USE_CASE_TEXT" \
        '{companyName:$cn, companyWebsite:$cw, intendedUsers:"0",
          industryOption:"Legal", otherIndustryOption:"", useCases:$uc}')
    else
      FORM_JSON=$(printf '{"companyName":"%s","companyWebsite":"%s","intendedUsers":"0","industryOption":"Legal","otherIndustryOption":"","useCases":"%s"}' \
        "$COMPANY_NAME" "$COMPANY_URL" "$USE_CASE_TEXT")
    fi
    if aws bedrock put-use-case-for-model-access \
         --region "$REGION" \
         --form-data "$(echo -n "$FORM_JSON" | base64 -w0)"; then
      ok "Use-case form submitted"
    else
      warn "Form submission was rejected. The data sent was:"
      echo "$FORM_JSON" | sed 's/^/    /'
      die "Fallback: open the Bedrock console → Chat/Text playground → pick a Claude model → submit the form there once, then re-run this script."
    fi
  fi

  # ── 2. §203 StGB hardening: model invocation logging OFF, EU-wide ──────────
  say "Step 2/6 — Professional secrecy check (§203 StGB): invocation logging"
  local r CFG
  for r in "${EU_REGIONS[@]}"; do
    CFG=$(aws bedrock get-model-invocation-logging-configuration \
            --region "$r" --output text 2>/dev/null || true)
    if [[ -n "$CFG" ]]; then
      warn "Invocation logging was ENABLED in ${r} — disabling now"
      aws bedrock delete-model-invocation-logging-configuration --region "$r" \
        && ok "Logging disabled in ${r}" \
        || warn "Could not disable logging in ${r} — do this manually in the Bedrock console (Settings)"
    fi
  done
  ok "Model invocation logging is OFF in all EU regions"
  ok "Prompt and response content is NOT logged or stored by Bedrock"
  echo "    NOTE: Never enable 'Model invocation logging' in the Bedrock console"
  echo "    settings — it would write mandate content to CloudWatch/S3 and"
  echo "    breach your §203 posture. Re-running this script re-checks it."

  # ── 3. Least-privilege IAM user ─────────────────────────────────────────────
  say "Step 3/6 — IAM user '${IAM_USER}'"
  if aws iam get-user --user-name "$IAM_USER" >/dev/null 2>&1; then
    ok "User already exists"
  else
    aws iam create-user --user-name "$IAM_USER" \
      --tags Key=managed-by,Value=bedrock-bootstrap >/dev/null
    ok "User created"
  fi

  # Invoke-only policy. Deliberately NOT AmazonBedrockLimitedAccess (too broad —
  # it includes guardrail/logging management, which we must keep locked down).
  local POLICY_DOC
  POLICY_DOC=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "InvokeAnthropicModels",
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel",
        "bedrock:InvokeModelWithResponseStream"
      ],
      "Resource": [
        "arn:aws:bedrock:*::foundation-model/anthropic.*",
        "arn:aws:bedrock:*:${ACCOUNT_ID}:inference-profile/eu.anthropic.*"
      ]
    },
    {
      "Sid": "ModelDiscovery",
      "Effect": "Allow",
      "Action": [
        "bedrock:ListFoundationModels",
        "bedrock:GetFoundationModel",
        "bedrock:ListInferenceProfiles",
        "bedrock:GetInferenceProfile"
      ],
      "Resource": "*"
    },
    {
      "Sid": "AllowBearerTokenAuth",
      "Effect": "Allow",
      "Action": "bedrock:CallWithBearerToken",
      "Resource": "*"
    },
    {
      "Sid": "DenyLoggingConfiguration",
      "Effect": "Deny",
      "Action": [
        "bedrock:PutModelInvocationLoggingConfiguration"
      ],
      "Resource": "*"
    }
  ]
}
EOF
)
  aws iam put-user-policy --user-name "$IAM_USER" \
    --policy-name "$POLICY_NAME" --policy-document "$POLICY_DOC"
  ok "Policy attached (invoke + model discovery, Anthropic EU only; logging config explicitly denied)"

  # ── 4. Long-term Bedrock API key ────────────────────────────────────────────
  say "Step 4/6 — Bedrock API key (expires in ${KEY_AGE_DAYS} days)"
  local EXISTING COUNT OLDEST KEY_JSON API_KEY attempt4
  EXISTING=$(aws iam list-service-specific-credentials \
    --user-name "$IAM_USER" --service-name bedrock.amazonaws.com \
    --query 'ServiceSpecificCredentials[].ServiceSpecificCredentialId' \
    --output text 2>/dev/null || true)
  COUNT=$(echo "$EXISTING" | wc -w)
  if [[ "$COUNT" -ge 2 ]]; then
    OLDEST=$(echo "$EXISTING" | awk '{print $1}')
    warn "User already has 2 API keys — deleting oldest (${OLDEST}) to rotate"
    aws iam delete-service-specific-credential \
      --user-name "$IAM_USER" --service-specific-credential-id "$OLDEST"
  fi

  KEY_JSON=""
  for attempt4 in 1 2 3; do
    if KEY_JSON=$(aws iam create-service-specific-credential \
        --user-name "$IAM_USER" \
        --service-name bedrock.amazonaws.com \
        --credential-age-days "$KEY_AGE_DAYS" \
        --output json 2>&1); then
      break
    fi
    warn "Key creation attempt ${attempt4} failed:"
    echo "$KEY_JSON" | sed 's/^/    /'
    KEY_JSON=""
    if [[ $attempt4 -lt 3 ]]; then
      warn "Retrying in 10s (newly created IAM users can take a moment to propagate)..."
      sleep 10
    fi
  done
  [[ -n "$KEY_JSON" ]] || die "Could not create the API key — see the error above."

  # The secret's field name varies across AWS docs/CLI versions
  # (ServiceApiKeyValue vs ServiceCredentialSecret vs ServicePassword) —
  # try each, then fall back to matching the ABSK... token pattern.
  API_KEY=$(echo "$KEY_JSON" | python3 -c '
import sys, json
try:
    c = json.load(sys.stdin).get("ServiceSpecificCredential", {})
except Exception:
    sys.exit(0)
for f in ("ServiceApiKeyValue", "ServiceCredentialSecret", "ServicePassword"):
    if c.get(f):
        print(c[f]); break
' 2>/dev/null || true)
  if [[ -z "$API_KEY" ]]; then
    API_KEY=$(echo "$KEY_JSON" | grep -o 'ABSK[A-Za-z0-9+/=]*' | head -n1 || true)
  fi
  if [[ -z "$API_KEY" ]]; then
    warn "Key was created, but its value could not be located in the response:"
    echo "$KEY_JSON" | sed 's/^/    /'
    die "Please send a screenshot of the response above to your administrator."
  fi
  ok "API key created (shown once — it cannot be retrieved again)"

  # ── 5. Warm-up invocation (triggers the Marketplace subscription) ───────────
  # The auto-subscription on first invoke requires aws-marketplace permissions,
  # which the Cowork key deliberately does NOT have. So we invoke the model
  # once HERE, as the admin — after that, the subscription is account-wide
  # and the invoke-only key works.
  say "Step 5/6 — Activating ${MODEL_ID} (Marketplace subscription)"
  local attempt
  for attempt in 1 2 3; do
    if aws bedrock-runtime converse \
        --region "$REGION" \
        --model-id "$MODEL_ID" \
        --messages '[{"role":"user","content":[{"text":"ping"}]}]' \
        --inference-config '{"maxTokens":1}' >/dev/null 2>&1; then
      ok "Model responded — Marketplace subscription active"
      break
    fi
    if [[ $attempt -lt 3 ]]; then
      warn "Not ready yet (first-time subscription can take up to 15 min). Retrying in 60s..."
      sleep 60
    else
      warn "Warm-up incomplete. The subscription may still be propagating — re-run this script in ~15 minutes; the API key below is already valid."
    fi
  done

  # ── 6. Emit Cowork 3P config JSON ────────────────────────────────────────────
  say "Step 6/6 — Cowork 3P configuration"
  local OUT_DIR="$HOME/cowork-3p-config"
  mkdir -p "$OUT_DIR"

  cat > "$OUT_DIR/cowork-3p-bedrock.json" <<EOF
{
  "provider": "bedrock",
  "awsRegion": "${REGION}",
  "bedrockBaseUrl": "",
  "bedrockServiceTier": "",
  "credentialKind": "static_api_key",
  "awsBearerToken": "${API_KEY}"
}
EOF
  chmod 600 "$OUT_DIR/cowork-3p-bedrock.json"

  echo
  echo "════════════════════════════════════════════════════════════════════"
  echo "  COPY THE JSON BELOW INTO YOUR COWORK 3P CONFIGURATION"
  echo "════════════════════════════════════════════════════════════════════"
  cat "$OUT_DIR/cowork-3p-bedrock.json"
  echo "════════════════════════════════════════════════════════════════════"
  cat <<EOF

  Also saved to: ${OUT_DIR}/cowork-3p-bedrock.json
  (CloudShell: Actions → Download file → paste that path)

  Field mapping in the Cowork Bedrock settings panel:
    AWS region           →  ${REGION}
    Bedrock base URL     →  leave empty
    Bedrock service tier →  leave unset (on-demand)
    Credential kind      →  Static API key
    AWS bearer token     →  the "awsBearerToken" value above

  MODELS section (below the credentials in Cowork):
    Model discovery  →  switch OFF
    Model list       →  "+ Add model" and enter exactly: ${MODEL_ID}
                        (first entry = default; keep it the only entry)
    To offer an additional Anthropic model later, activate it first by
    re-running this script, e.g.:
      MODEL_ID=eu.anthropic.claude-sonnet-4-6 bash bedrock-bootstrap.sh
    then add that ID to the Model list.

  §203 StGB posture summary (verified by this run):
    • Model invocation logging: OFF in all EU regions
    • Inference: EU geo cross-region profile only (never leaves EU regions)
    • Credential scope: invoke-only; logging configuration explicitly DENIED
    • Bedrock does not store prompts/responses; content is not used
      for model training
    • Reminder: request the AWS professional-secrecy addendum (§203 StGB
      Zusatzvereinbarung) via an AWS Support case if not yet in place

  Key management:
    • The key expires in ${KEY_AGE_DAYS} days. Re-run this script to rotate.
    • When Anthropic releases NEW models, re-run this script once to
      activate them — the Cowork key alone cannot trigger the required
      Marketplace subscription (by design).
    • To revoke immediately:
        aws iam list-service-specific-credentials --user-name ${IAM_USER} --service-name bedrock.amazonaws.com
        aws iam delete-service-specific-credential --user-name ${IAM_USER} --service-specific-credential-id <ID>
EOF
}

main "$@"
