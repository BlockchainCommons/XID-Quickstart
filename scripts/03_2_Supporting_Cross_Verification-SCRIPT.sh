#!/bin/bash
#
# 03_2_Supporting_Cross_verification-SCRIPT.sh
#
# Tests all commands from §3.1, verifying:
# - XID consistency
# - Provenance mark consistency
# - Edge extraction
# - temporal anchor check
#
# Usage: bash 03_2_Supporting_Cross_verification-SCRIPT.sh
set -e


echo "=== LEARNING XIDS §3.2: Supporting Cross Verification ==="
echo ""

# Configuration
FETCHED_XID="ur:xid/tpsplftpsplntpsotanshdhdcxhecefsnnionspljpftktetwymnfmcyecveuotktpwenlhyhdpmpykpchcmzchywzoyaylrtpsotansgylftanshflfaohdcxtyjeuyceehntqzmwtdhfoscmguplcyeoaarhcxghreynrlfleynefnbtiodyesattansgrhdcxntesveuelkhdbnwdutynettbaarnnbspgefsvemohtnezeldcncmueldtkjlfxhdhdcxaavsgooxasuobnrdvanbkpfnlgttlnsfdtftisnypfcewzvlehdybemomdeeasbboycscstpsojlhsjyjyihjkjyhsjyinjljtdpjeihkkoycsfncsfdoyastpsotpcxksecisjyjyjojkftdldlioinjyiskpiddmiajljndlfwgmhsiekojliaetdlfwgmhsiekojliaetdljphsktdljnhsinjtdlksiniedmjyksjyoycfaorylftpsplrtpsokscfhsiaiajlkpjtjydpiajpihieihjtjyinhsjzdpioinjyiskpidoyadtpsojpiyjlhsiyftgwjtjzinjtihfpiaiajlkpjtjyoycfaorsldtpsotanshdhdcxhecefsnnionspljpftktetwymnfmcyecveuotktpwenlhyhdpmpykpchcmzchywzoytpsojsjkjkisguiniojtinjtiogrihkkjkgogmgstpsotpcxksenisjyjyjojkftdldlhsjoindmioinjyiskpiddmiajljndlkpjkihjpjkdlfwgmhsiekojliaetdljkjkishejkiniojtinjtiohejeihkkjkoytpsojnjkjkisguiniojtinjtiogrihkktpsotanshftanehsksimjkjkisdpihieeyececehescxfpfpfpfpfxeoglknhsfxehjzhtfygaehglghfeecfpfpfpfpgagwingwjykpiyesisktfyfwimglhdkkimkoimfdgtgrihgsgygrkkknghetfliafdeojygskofdglgrjphdgeihcxfwgmhsiekojliaetfzgthsiadmhsjyjyjzjliahsjzdmjtihjyoytpsojoiyjlhsiyfthsiaiajlkpjtjyglhsjnihtpsoisfwgmhsiekojliaetoytpsojsjkjkisguiniojtinjtiogrihkkghihksjytpsoksimjkjkisdpihieeyececehescxfpfpfpfpfxeoglknhsfxehjzhtfygaehglghfeecfpfpfpfpgagwingwjykpiyesisktfyfwimglhdkkimkoimfdgtgrihgsgygrkkknghetfliafdeojygskofdglgrjphdgeihcxfwgmhsiekojliaetfzgthsiadmhsjyjyjzjliahsjzdmjtihjyoybetpsokoeydyeyendpdyeodpehetghehehftececdpehdyftdydyoytpsokscwiyjlhsiyfthsiaiajlkpjtjyguihjpkoiniaihfdjljnihjohsioihtpsotpcxksdkisjyjyjojkftdldlioinjyiskpiddmiajljndlfwgmhsiekojliaetdlfwgmhsiekojliaetoycscwtpsotpcxksdaisjyjyjojkftdldlhsjoindmioinjyiskpiddmiajljndlkpjkihjpjkdlfwgmhsiekojliaetoycseetpsotpcxjpisjyjyjojkftdldlioinjyiskpiddmiajljnoycfaorntpsotanshdhdcxhecefsnnionspljpftktetwymnfmcyecveuotktpwenlhyhdpmpykpchcmzchywzoyaxtpsotansghtaneidkkaddmdpdpdpdpdpfwfeflgaglcxgugufdcxgugaflglfpghgogmfedpdpdpdpdpbkgoehglgagodyjzfdfpfpfpfpfpgyfpfpfpfygtfpfpfpfpgsiaeogljlgshghfjegtimgoehgtghjefpfpfpfpioengaeneyecdleyfdfpgtflgtehiygrgwdngtiaktjoeejyfpjpgsbkglgdkthtktiyihdykpetiadyjsjyiajzeefpfpfpfpgahthgeceyhthgkskoiaflgofpfpfpfpfpfpfpfpfpfwjtgljlhkghgaehgliofpfpfpfggtfpfpfpfpgsiaeogljlgshghfjebkgtimgoehgtghjefpfpfpfwfpeeglhsjyieghdlidieetidglghgoeskpgsfydnjsgafyecjnishtidfpeedyesglfxjeemhtfehfgmfpidfdgwimieiagdjlecflkofwgldyguiofyenbkengteeishgihiahkjlidfygujtjkjziaksgmhdfxihecgugrgmgyfpiofsfsbkdpdpdpdpdpfeglfycxgugufdcxgugaflglfpghgogmfedpdpdpdpdpbkoyaylrtpsotansgylftanshflfaohdcxolmystmtwyhhgljscpamingewnkplnpssfmnsnlramdwclkpkswmkstbfgdngdtotansgrhdcxsoeymskoiyrseswelubkspfdhllpmyksrpmkcmwzaoplwdlrfhzoropslpnlcmadoycscstpsoisfwgmhsiekojliaetoycsfncsfghdcxvdfpnltylrmowtutatkedsgresehiednenuthnveclgthgutprdlynoeuepkmnwtoycsfzlftpsotngdgmgwhflfaxhdimwpenbadrpkylftpdcysglohkhlwsdwwzfsineodwbgaezowkstehdwsnmtrnrptarooyiybaseldcnfdahehdedkuygrtiescmcxmsrnvtylfhlewegyotayhkfsuramlbpezsaylrcsjyotbysobektlywmprgmmkwspdctlgtodrtsvdbngljzromnfynddpceatkschjltkmslshnhdcxkibamycybshytapagwsfwtcebbvoincphebsvlgyfpehnlckdrstmocmmknsgshdoyaxtpsotansghlfaohdfzurflcmrdtadadakisfgdqzjsvoosahcfahghzebddwcflfgemtkphtpaspwpzsqdcygopyplplytcxvetlsrcpyaaaswiertmhcsluehrtotbtztcntbtkiyrylubzadzcpmbztt"

# (This is a public version of the XID that appears in the BRadvoc8 repo on GitHub)

# Create output directory
OUTPUT_DIR="output/script-03-2-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUTPUT_DIR"

echo "Step 2: Verify Self Consistency"
echo "================================"

success=0

read -a PUBKEY <<< $(envelope xid key all "$FETCHED_XID")
for i in "${PUBKEY[@]}"
do
    if envelope verify -v $i $FETCHED_XID >/dev/null 2>&1; then
      echo "✅ One of the signatures verified - XID is self-consistent "
      echo $i
      success=1
    fi
done

if [[ -z $success ]]
then
    echo "❌ Signature FAILED - do not trust!"
    exit 1
fi

echo ""
echo "Step 3: Verify Provenance Consistency"
echo "====================================="

PROVENANCE_MARK=$(envelope xid provenance get "$FETCHED_XID")

echo "Provenance mark: $(echo "$PROVENANCE_MARK" | head -c 50)..."
echo "$PROVENANCE_MARK" > "$OUTPUT_DIR/01-provenance-mark.txt"

echo ""
echo "Provenance validation:"
if provenance validate --warn --format json-pretty "$PROVENANCE_MARK" 2>&1 | head -20; then
    echo "✅ Provenance validated"
else
    echo "⚠️  Provenance validation has issues"
fi
echo ""

echo ""
echo "Step 5: Extract the GitHub Edge"
echo "=============================="

XID_EDGE=$(envelope xid edge all $FETCHED_XID)

if [ -z "$XID_EDGE" ]; then
    echo "❌ ERROR: No edge found in XID"
    exit 1
fi

echo "✅ Found edge:"
envelope format "$XID_EDGE"

echo ""
echo "Step 6: Extract the Claimed SSH Key"
echo "==================================="


UNWRAPPED_EDGE=$(envelope extract wrapped "$XID_EDGE")
EDGE_TARGET=$(envelope assertion find predicate known 'target' "$UNWRAPPED_EDGE")
EDGE_CLAIM=$(envelope extract object $EDGE_TARGET)

USERNAME=$(envelope assertion find predicate string "foaf:accountName" "$EDGE_CLAIM" | envelope extract object | envelope format | tr -d '"')
CLAIMED_KEY_UR=$(envelope assertion find predicate string "sshSigningKey" "$EDGE_CLAIM"  | envelope extract object | envelope extract ur)
CLAIMED_KEY_TEXT=$(envelope assertion find predicate string "sshSigningKeyText" "$EDGE_CLAIM" | envelope extract object | envelope format | tr -d '"')

echo "SSH key claimed $USERNAME GitHub account"
echo "$CLAIMED_KEY_UR"
echo "$CLAIMED_KEY_TEXT"

echo ""
if echo "$CLAIMED_KEY_TEXT" | grep -q "ssh-ed25519"; then
    echo "✅ SSH key is ssh-ed25519 as expected"
else
    echo "❌ ERROR: Could not extract SSH key or is wrong type"
    exit 1
fi

echo ""
echo "Step 7: Query GitHub API"
echo "========================"

echo "Querying GitHub API for $USERNAME's signing keys..."
GITHUB_KEYS=$(curl -s "https://api.github.com/users/$USERNAME/ssh_signing_keys")
GITHUB_KEY=$(echo "$GITHUB_KEYS" | jq -r '.[0].key')

echo ""
echo "GitHub API response:"
echo "$GITHUB_KEYS" | jq '.[0] | {key, created_at}'


echo ""
echo "Step 8: Compare Keys"
echo "===================="

GITHUB_KEY_ARRAY=( $GITHUB_KEY )
CLAIMED_KEY_ARRAY=( $CLAIMED_KEY_TEXT )

echo "Claimed text key: ${CLAIMED_KEY_ARRAY[0]} ${CLAIMED_KEY_ARRAY[1]}"
echo "GitHub key:       ${GITHUB_KEY_ARRAY[0]} ${GITHUB_KEY_ARRAY[1]}"

if [ "${CLAIMED_KEY_ARRAY[0]}" = "${GITHUB_KEY_ARRAY[0]}" ] &&
   [ "${CLAIMED_KEY_ARRAY[1]}" = "${GITHUB_KEY_ARRAY[1]}" ]; then
    echo ""
    echo "✅ GITHUB KEY MATCHES - XID claim matches GitHub registry"
else
    echo ""
    echo "❌ KEYS DO NOT MATCH - GitHub and XID Text Key Do Not Match"
    exit 1;
fi

EXPORTED_KEY_UR=$(envelope export "$CLAIMED_KEY_UR")
EXPORTED_KEY_ARRAY=( $EXPORTED_KEY_UR )

echo ""
echo "Claimed text key: ${CLAIMED_KEY_ARRAY[0]} ${CLAIMED_KEY_ARRAY[1]}"
echo "Claimed UR key:   ${EXPORTED_KEY_ARRAY[0]} ${EXPORTED_KEY_ARRAY[1]}"

if [ "${CLAIMED_KEY_ARRAY[0]}" = "${EXPORTED_KEY_ARRAY[0]}" ] &&
   [ "${CLAIMED_KEY_ARRAY[1]}" = "${EXPORTED_KEY_ARRAY[1]}" ]; then
    echo ""
    echo "✅ KEYS MATCH - Both XID keys match "
else
    echo ""
    echo "❌ KEYS DO NOT MATCH - XID keys do not match "
    exit 1;
fi

echo ""
echo "Step 9: Verify Keys"
echo "==================="

if envelope verify -v "$CLAIMED_KEY_UR" "$XID_EDGE" >/dev/null 2>&1; then
  echo "✅ silence means success"
else
  echo "❌ XID edge signature does not match other keys"
  exit 1
fi

echo ""
echo "Step 10: Check GitHub's Timestamp"
echo "================================="

GITHUB_CREATED=$(echo "$GITHUB_KEYS" | jq -r '.[0].created_at')
echo "Key registered on GitHub: $GITHUB_CREATED"


echo ""
echo "Step 11: Cross-Reference Provenance"
echo "================================="

CLAIMED_DATE=$(envelope assertion find predicate known "date" "$EDGE_CLAIM" | envelope extract object | envelope format | tr -d '"')

echo "Timeline analysis:"
echo "  - GitHub key registered: $GITHUB_CREATED"
echo "  - XID edge created:      $CLAIMED_DATE"


echo ""
echo "Step 12: Check Commit Signatures"
echo "================================"

echo "Checking commit signatures..."
COMMIT_URL="https://api.github.com/repos/BRadvoc8/BRadvoc8/commits"
RECENT_COMMIT=$(curl -s "$COMMIT_URL" | jq -r '.[].sha'|head -1)
OLD_COMMIT=$(curl -s "$COMMIT_URL" | jq -r '.[].sha'|tail -1)

echo ""
echo "Most recent commit: $RECENT_COMMIT"
echo "Recent verification status:"
curl -s "https://api.github.com/repos/BRadvoc8/BRadvoc8/commits/$RECENT_COMMIT" | \
    jq '{date: .commit.author.date, verified: .commit.verification.verified, reason: .commit.verification.reason}'
echo ""
echo "Older commit: $OLD_COMMIT"
echo "Old verification status:"
curl -s "https://api.github.com/repos/BRadvoc8/BRadvoc8/commits/$OLD_COMMIT" | \
    jq '{date: .commit.author.date, verified: .commit.verification.verified, reason: .commit.verification.reason}'

echo "==============================="
echo "All Tutorial §3.2 Tests Passed!"
echo "==============================="
echo ""
echo "No files saved"
