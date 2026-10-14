#!/usr/bin/env bash
# Optional bonus: ask a model on Amazon Bedrock. Needs model access enabled in the console (Bedrock -> Model access).
. "$(dirname "$0")/_common.sh"
PROMPT="${*:-Explain cloud computing to a complete beginner in 3 short lines, using one everyday analogy.}"
pick(){ aws bedrock list-foundation-models --query "modelSummaries[?contains(modelId,'$1') && contains(inferenceTypesSupported,'ON_DEMAND') && contains(outputModalities,'TEXT')].modelId | [0]" --output text 2>/dev/null; }
MODEL="${MODEL_ID:-$(pick claude)}"; [ "$MODEL" = "None" ] || [ -z "$MODEL" ] && MODEL="$(pick nova)"
[ "$MODEL" = "None" ] || [ -z "$MODEL" ] && die "No on-demand text model visible. Enable model access in the Bedrock console, or set MODEL_ID=..."
bold "Asking $MODEL in $AWS_REGION"
echo "  Q: $PROMPT"; echo
aws bedrock-runtime converse --model-id "$MODEL" \
  --messages "[{\"role\":\"user\",\"content\":[{\"text\":$(jq -Rn --arg p "$PROMPT" '$p')}]}]" \
  --inference-config '{"maxTokens":300}' --query 'output.message.content[0].text' --output text
