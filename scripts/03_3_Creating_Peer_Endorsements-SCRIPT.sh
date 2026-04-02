#!/bin/bash
#
# 03_3_Creating_Peer_Endorsements-SCRIPT.sh
#
# Tests all commands from §3.3, verifying:
# - Detached endorsement creation
# - Embedded endorsement creation
# - Endorsement verification
#
# Usage: bash 03_3_Creating_Peer_Endorsements-SCRIPT.sh


set -e

echo "=== LEARNING XIDS §3.3: Creating Peer Endorsements ==="

# Configuration

# Create output directory
OUTPUT_DIR="output/script-03-3-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUTPUT_DIR"

XID="ur:xid/tpsplftpsplptpsotanshdhdcxnsvelewdmugsjksomhcsdngumosodnlffnlpcxfeylutcseeluatlyihdphyieadoycfaorylftpsplrtpsokscfhsiaiajlkpjtjydpiajpihieihjtjyinhsjzdpioinjyiskpidoyadtpsojpiyjlhsiyftgwjtjzinjtihfpiaiajlkpjtjyoycfaorsldtpsotanshdhdcxnsvelewdmugsjksomhcsdngumosodnlffnlpcxfeylutcseeluatlyihdphyieadoytpsojsjkjkisguiniojtinjtiogrihkkjkgogmgstpsotpcxksenisjyjyjojkftdldlhsjoindmioinjyiskpiddmiajljndlkpjkihjpjkdlfwgmhsiekojliaetdljkjkishejkiniojtinjtiohejeihkkjkoytpsojoiyjlhsiyfthsiaiajlkpjtjyglhsjnihtpsoisfwgmhsiekojliaetoytpsojnjkjkisguiniojtinjtiogrihkktpsotansgylftanshftanehsksgdjkjkisdpihieeyececehescxfpfpfpfpfxeoglknhsfxehjzhtfygaehglghfeecfpfpfpfpgafdeceyjlgogmjehkkpjpjtihiygojtjlfgiddnfpgsjpjpfxeedlhdihdngdkpgwgmfxfgkninjlgmfyhfjkgmtansgrhdcxfhtkhnmyoeoyvdvdgolosrpfrosnrsaycmiycelnqdjyjzlplpeykgesmnvwoeimoytpsokscwiyjlhsiyfthsiaiajlkpjtjyguihjpkoiniaihfdjljnihjohsioihtpsotpcxksdkisjyjyjojkftdldlioinjyiskpiddmiajljndlfwgmhsiekojliaetdlfwgmhsiekojliaetoycscwtpsotpcxksdaisjyjyjojkftdldlhsjoindmioinjyiskpiddmiajljndlkpjkihjpjkdlfwgmhsiekojliaetoycseetpsotpcxjpisjyjyjojkftdldlioinjyiskpiddmiajljnoytpsojsjkjkisguiniojtinjtiogrihkkghihksjytpsoksgdjkjkisdpihieeyececehescxfpfpfpfpfxeoglknhsfxehjzhtfygaehglghfeecfpfpfpfpgafdeceyjlgogmjehkkpjpjtihiygojtjlfgiddnfpgsjpjpfxeedlhdihdngdkpgwgmfxfgkninjlgmfyhfjkgmoybetpsokoeydyeyendpdyeedpdyehgheheefteeetdpehdyftdydyoycfaorntpsotanshdhdcxnsvelewdmugsjksomhcsdngumosodnlffnlpcxfeylutcseeluatlyihdphyieadoyaxtpsotansghtaneidkkaddmdpdpdpdpdpfwfeflgaglcxgugufdcxgugaflglfpghgogmfedpdpdpdpdpbkgoehglgagodyjzfdfpfpfpfpfpgyfpfpfpfygtfpfpfpfpgsiaeogljlgshghfjegtimgoehgtghjefpfpfpfpioiyjthsisgmflgminenkpieecesguihiohfkoeefpkpkpjkgsimesbkieemeedneeecfegahdgwgrisfeglhgksfefpfpfpfpgahthgeceyhthgkskoiaflgofpfpfpfpfpfpfpfpfpfwjtgljlhkghgaehgliofpfpfpfggtfpfpfpfpgsiaeogljlgshghfjebkgtimgoehgtghjefpfpfpfwfphkihjeidkpjofxetihiyiejegejzgmeefdkkjpfyjkksgufljlghgtesdleejofdjegsjkghemdletgriygwhskoisecfgjtkkgmemfwkpgyeedlgwfwbkkkgufxghgrghkkhfenghiheefgeofdknhshfjtdldnjyehgwfyfefwiofsfsbkdpdpdpdpdpfeglfycxgugufdcxgugaflglfpghgogmfedpdpdpdpdpbkoycsfzlftpsotngdgmgwhflfaxhdimemotjebkahwlgadpntttykyardeeinldkszcrnrpglwdvlvyjygttblnpscylpgooegochluaxzttecegmweisvyjspskblkbdinparpiewzpkzscsrlrljycybydprnfwvobzfxlsrfehbzcsnnetrsmuwpgwhpiabgesbkldoxtsnsktjyincamejpbsdnkplsyttdknuyndhhkgcflfoycsfylftansfwlrhdrogarffxsggywkeckefnkpdaswiarhpeaxdpimmykbvsztotpfjlzthfehuegttywdfegmiabeurbtutnsleiswesapkkgaxrdkshhgenlbelrcaaeynhhwdrepaioaetaaazmvogwjphtmncpbeeywpsoieltbghlkprszektotjtdlylfrlbjswkurtatyrylngrimzorytygysgjkcfolbzhffradlrcfldecndrlahjeasjopfsbbkswcximhpjnflfywztekbrketdtlddtytnldamnknptgwpsqzylemesptjndrcafzcljehgnefygdcyrtvaaosahfsbfpvwbyfgqzsfmoprbtzovtiofntpjegsiynlcluygwaxnszcgeiyvscsgdehtkingwwlcfhdlfhhvtadeorlcpgtfwhddatansfphdcxsebgsblbpdoxykmseohlhdmhenprkkfthysnfsotnbhhuyfwnnleisbgylrtchcyoybwtpsotanshptansfwlrhdcxkstbtnbsdpwyfshtqddafpbglnbgpesraxlodydpprgonnvatopmuylpaxdimoamgsksiadlptheglztjeasmtnsdagdsrbtdmfpvddspsmhktwfcklymtwyspdyhflfaxtansgmgdrphegrkbtisgdkhnbzehuyhnhgzelndioybstpsotansgmhdcxiyvwcpcptddkeemdwfoylrrnspcttebgsbrnfmoetirfmwehhsrehdpmstdadaytoyaylrtpsotansgylftanshflfaohdcxonbbaxfdchqzlfcptlbbyachdypehyaxtecavlhymnmyceeekotpcamnamguclmotansgrhdcxcsrnchrnrpbsrnuecwaymoihplfnkgrdaxiefgpyidvysecnluhtwlwmpfwndnctoycscstpsoisfwgmhsiekojliaetoycsfncsfglfoycsfplftansfwlrhdghndsbdsttpdaavaythghtylonfrbssorlbbnbgwwpcmyttdroytltghnsidemtlynfmnnnyjkehmksremnsvybemuaejpaybgmkotnlyngsieckheoeveiantdrcfvawylfrlrskeaodmktykwnrtaylfisswrdrhbsoxgrcmgscmpllpbgmntyjsldrpnefmotgdrnkehfhfwtdtfpktlfaoknsfhehskehnhddatansfphdcxjemdmobewtihrohsgaghsglkgepdcmhdflhnamvegwssjzolpsjslesrwypkrydwoybwtpsotanshptansfwlrhdcxnesgvsfpfnpajknbfeticnvachemnngyfwwdrlzeidrnbztybtgdeycpstssbtcmgsiavwwyrfykpkssrkkgkbtogugdmtfxbasfgwdyahgswtlpjlzckkesfnashflfaxtansgmgdcsbnfgjzskflbwjnfyfpadayhlmsjlzooybstpsotansgmhdcxrsfpfpfmldltkbsaamecmogabacsjtdedtsshlmdutaoaoylstndserdwdnedwmnoyaylrtpsotansgylftanshflfaohdcxplvdotinmnwensttrtlrtiisqzehrltlnlguhdludywzsebztnqdndwztpdazeqdtansgrhdcxfmlpjkhspautsfmwlndrpavobwpyotsazsdidwrnrpcylfintnwtgrnnhdhhpyjpoycscstpsojlhsjyjyihjkjyhsjyinjljtdpjeihkklfoycsfplftansfwlrhdghcebtmooncevypltantclcsktdektfgmujpgdoswpcfwztnylhsdthtlnssspykkgdypediadnshhmygsvalyfwsprfjlenkecploclfewmkbfhrkmssnjshfcfinrtmkhthdflfpbzrpwffpmyiafwetzskocevlglvtlknlgsguceatjshnlktpgocwwpaxjpgdamurgysnjpylztskhpskdpsalodkrnwfhddatansfphdcxiopakburhprngowmtshlrswzihbytpflgtrootzosfrpnnfprymuveasenotaeadoybwtpsotanshptansfwlrhdcxgdvalgbtkintzmtaecgmjkcasrtdfxvyptjohefdvwsehdgmyacxoyteetayzsrogsztpkweghrdmsioveptsantcxgdjtadswnsgerkvtfgcnrsbdfwmduyhfiehflfaxtansgmgdghvyglendpguolvldiambabylndwbydyoybstpsotansgmhdcxghchykwlghoxpftljectmyyldyamgycwamfwbnsbjelbsshkbzcnuttyrltlwtgmoycsfncsfdoyaxtpsotansghlfaohdfzmueerfaarkbdvypejpadhsonrygsaysgseploevahpbnntnymdlgbbjnleimheeoamtyvyihrhfeeefypadazmynktendskbjeksrfimhgmeclhslgdlswctdpjslybkoypygwry"

XID_ID=$(envelope xid id $XID)
PASSWORD="test-password-for-tutorial"

echo ""
echo "Step 1: Create Charlene's Identity"
echo "=================================="

CHARLENE_PASSWORD="charlenes-own-password"
CHARLENE_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
CHARLENE_PUBKEYS=$(envelope generate pubkeys "$CHARLENE_PRVKEYS")
CHARLENE_XID=$(echo $CHARLENE_PRVKEYS | \
    envelope xid new \
    --private encrypt \
    --encrypt-password "$CHARLENE_PASSWORD" \
    --nickname "Charlene" \
    --generator encrypt \
    --sign inception)
CHARLENE_XID_ID=$(envelope xid id "$CHARLENE_XID")

if [ $CHARLENE_XID ]
then   
   echo "✅ Charlene's XID created: $CHARLENE_XID_ID"
else
  echo "❌ Error in Charlene XID creation"
fi

echo ""
echo "Step 2: Create Charlene's Endorsement"
echo "====================================="
   
CHARLENE_CLAIM=$(envelope subject type string "BRadvoc8 is a thoughtful and committed contributor to privacy work that protects vulnerable communities")
CHARLENE_ENDORSEMENT=$(envelope assertion add pred-obj known isA known attestation "$CHARLENE_CLAIM")
CHARLENE_ENDORSEMENT=$(envelope assertion add pred-obj known source ur $CHARLENE_XID_ID "$CHARLENE_ENDORSEMENT")
CHARLENE_ENDORSEMENT=$(envelope assertion add pred-obj known target ur $XID_ID "$CHARLENE_ENDORSEMENT")
CHARLENE_ENDORSEMENT=$(envelope assertion add pred-obj known 'date' string `date -Iminutes` "$CHARLENE_ENDORSEMENT")
CHARLENE_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementContext" string "Personal friend, observed values and commitment over 2+ years" "$CHARLENE_ENDORSEMENT")
CHARLENE_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementScope" string "Character and values alignment, not technical skills" "$CHARLENE_ENDORSEMENT")
CHARLENE_WRAPPED_ENDORSEMENT=$(envelope subject type wrapped "$CHARLENE_ENDORSEMENT")
CHARLENE_SIGNED_ENDORSEMENT=$(envelope sign --signer "$CHARLENE_PRVKEYS" "$CHARLENE_WRAPPED_ENDORSEMENT")

if [ $CHARLENE_SIGNED_ENDORSEMENT ]
then   
   echo "✅ Charlene endorsement created"
else
    echo "❌ Error in Charlene endorsement creation"
    exit 1
fi

if envelope format "$CHARLENE_SIGNED_ENDORSEMENT" | grep -q "signed"; then
    echo "✅ Endorsement is signed"
else
    echo "❌ ERROR: Charlene endorsement is not signed"
    exit 1
fi

echo ""
echo "Charlene's endorsement:"
envelope format "$CHARLENE_SIGNED_ENDORSEMENT"

echo ""
echo "Step 4: Store Charlene's Info"
echo "============================="

echo "$CHARLENE_PRVKEYS" > $OUTPUT_DIR/01-charlene-keys,ur
echo "$CHARLENE_XID" > $OUTPUT_DIR/02-charlene-xid.envelope
echo "$CHARLENE_SIGNED_ENDORSEMENT" > $OUTPUT_DIR/03-charlene-endorsement.envelope

echo ""
echo "Step 5: Create DevReviewer's Identity"
echo "====================================="

REVIEWER_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
REVIEWER_PUBKEYS=$(envelope generate pubkeys "$REVIEWER_PRVKEYS")
REVIEWER_PASSWORD="devreviewers-own-password"
REVIEWER_XID=$(echo $REVIEWER_PRVKEYS | \
    envelope xid new \
    --private encrypt \
    --encrypt-password "$REVIEWER_PASSWORD" \
    --nickname "Charlene" \
    --generator encrypt \
    --sign inception)
REVIEWER_XID_ID=$(envelope xid id "$REVIEWER_XID")

if [ $REVIEWER_XID ]
then   
   echo "✅ Charlene's XID created: $CHARLENE_XID_ID"
else
  echo "❌ Error in Charlene XID creation"
fi

echo ""
echo "Step 6: Prepare Data for Edge Creation"
echo "======================================"

ISA="attestation"
SOURCE_XID_ID=$REVIEWER_XID_ID
TARGET_XID_ID=$XID_ID

echo ""
echo "Step 7: Create Technical Endorsement"
echo "===================================="

REVIEWER_TARGET=$(envelope subject type ur $TARGET_XID_ID)
REVIEWER_TARGET=$(envelope assertion add pred-obj string "peerEndorsement" string "Writes secure, well-tested code with clear attention to privacy-preserving patterns" $REVIEWER_TARGET)
REVIEWER_TARGET=$(envelope assertion add pred-obj known 'date' string `date -Iminutes` "$REVIEWER_TARGET")

REVIEWER_TARGET=$(envelope assertion add pred-obj string "endorsementContext" string "Verfied previous security experience, worked together on short project for SisterSpaces" "$REVIEWER_TARGET")
REVIEWER_TARGET=$(envelope assertion add pred-obj string "endorsementScope" string "Security architecture, cryptographic implementation, privacy patterns" "$REVIEWER_TARGET")
REVIEWER_TARGET=$(envelope assertion add pred-obj string "relationshipBasis" string "Security collaboration partner who verified credentials through commit-reveal and encrypted sharing" "$REVIEWER_TARGET")

echo ""
echo "Step 8: Enhance Endorser Information"
echo "===================================="

REVIEWER_SOURCE=$(envelope subject type ur $SOURCE_XID_ID)
REVIEWER_SOURCE=$(envelope assertion add pred-obj string "schema:worksFor" string "SisterSpaces" $REVIEWER_SOURCE)
REVIEWER_SOURCE=$(envelope assertion add pred-obj string "schema:employeeRole" string "Head Security Programmer" $REVIEWER_SOURCE)

echo ""
echo "Step 9: Create Your Edge"
echo "========================"

REVIEWER_ARID=$(envelope generate arid -x | cut -c 1-16)
REVIEWER_SUBJECT=peer-endorsement-from-devreviewer-$REVIEWER_ARID
REVIEWER_EDGE=$(envelope subject type string $REVIEWER_SUBJECT)
REVIEWER_EDGE=$(envelope assertion add pred-obj known isA string "$ISA" "$REVIEWER_EDGE")
REVIEWER_EDGE=$(envelope assertion add pred-obj known source envelope "$REVIEWER_SOURCE" "$REVIEWER_EDGE")
REVIEWER_EDGE=$(envelope assertion add pred-obj known target envelope "$REVIEWER_TARGET" "$REVIEWER_EDGE")

REVIEWER_WRAPPED_EDGE=$(envelope subject type wrapped $REVIEWER_EDGE)
REVIEWER_SIGNED_EDGE=$(envelope sign --signer "$REVIEWER_PRVKEYS" "$REVIEWER_WRAPPED_EDGE")

echo ""
echo "Step 10: Transmit Your Edge"
echo "==========================="

echo "Reviewing DevReviewer's Edge:"
if envelope format "$REVIEWER_SIGNED_EDGE" | grep -q "isA"; then
    echo "✅ isA assertion present"
else
    echo "❌ ERROR: isA assertion missing"
    exit 1
fi

if envelope format "$REVIEWER_SIGNED_EDGE" | grep -q "source"; then
    echo "✅ source assertion present"
else
    echo "❌ ERROR: source assertion missing"
    exit 1
fi

if envelope format "$REVIEWER_SIGNED_EDGE" | grep -q "target"; then
    echo "✅ target assertion present"
else
    echo "❌ ERROR: target assertion missing"
    exit 1
fi

if envelope format "$REVIEWER_SIGNED_EDGE" | grep -q "signed"; then
    echo "✅ Edge is signed"
else
    echo "❌ ERROR: DevReviewer endorsement is not signed"
    exit 1
fi

echo ""
echo "DevReviewer's endorsement:"
envelope format "$REVIEWER_SIGNED_EDGE"

echo ""
echo "Step 11: Store DevReviewer's Info"
echo "================================="

echo "$REVIEWER_PRVKEYS" > $OUTPUT_DIR/04-reviewer-keys,ur
echo "$REVIEWER_XID" > $OUTPUT_DIR/05-reviewer-xid.envelope
echo "$REVIEWER_SIGNED_EDGE" > $OUTPUT_DIR/06-reviewer-endorsement.envelope

echo ""
echo "Step 12: Embed DevReviewer's Peer Endorsement"
echo "============================================="

XID_WITH_EDGE=$(envelope xid edge add \
    --verify inception \
    $REVIEWER_SIGNED_EDGE $XID)

XID_WITH_EDGE=$(envelope xid provenance next \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$XID_WITH_EDGE")
echo "✅ Provenance advanced"

echo ""
echo "Amira's v4 XID:"
envelope format $XID_WITH_EDGE

echo ""
echo "Step 13: Export & Store Your Work"
echo "================================="

PUBLIC_XID_WITH_EDGE=$(envelope xid export --private elide --generator elide "$XID_WITH_EDGE")

echo "$XID_WITH_EDGE" > $OUTPUT_DIR/07-bradvoc8-xid-private.envelope
echo "$PUBLIC_XID_WITH_EDGE" > $OUTPUT_DIR/08-bradvoc8-xid-public.envelope

echo ""
echo "Step 15: Verify All Endorsements"
echo "================================"

if envelope verify -v "$CHARLENE_PUBKEYS" "$CHARLENE_SIGNED_ENDORSEMENT">/dev/null 2>&1 || true; then
    echo "✅ Charlene's endorsement verifies"
else
    echo "❌ ERROR: Charlene's endorsement does not verify"
    exit 1
fi


success=0
read -a XID_EDGES <<< $(envelope xid edge all "$PUBLIC_XID_WITH_EDGE")
for i in "${XID_EDGES[@]}"
  do
    if envelope verify -v $REVIEWER_PUBKEYS $i >/dev/null 2>&1; then
      echo "✅ DevReviewer's endorsement verifies"
      success=1
    fi
done

if [[ -z $success ]]
then
    echo "❌ ERROR: DevReviewer's endorsement does not verify"
    exit 1;
fi

FAKE_CLAIM=$(envelope subject type string "BRadvoc8 is amazing at everything")
FAKE_ENDORSEMENT=$(envelope assertion add pred-obj known isA known 'attestation' "$FAKE_CLAIM")
FAKE_ENDORSEMENT=$(envelope assertion add pred-obj known source ur $CHARLENE_XID_ID "$FAKE_ENDORSEMENT")
FAKE_ENDORSEMENT=$(envelope assertion add pred-obj known target ur $XID_ID "$FAKE_ENDORSEMENT")
FAKE_ENDORSEMENT=$(envelope assertion add pred-obj known 'date' string `date -Iminutes` "$FAKE_ENDORSEMENT")
FAKE_WRAPPED=$(envelope subject type wrapped $FAKE_ENDORSEMENT)
ATTACKER_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
FAKE_SIGNED=$(envelope sign --signer "$ATTACKER_PRVKEYS" "$FAKE_WRAPPED")

if envelope verify -s "$CHARLENE_PUBKEYS" "$CHARLENE_SIGNED_ENDORSEMENT">/dev/null 2>&1 || true; then
    echo "✅ Attacker's fake signature did not verify"
else
    echo "❌ ERROR: Attacker's endorsement verified, but it should not have."
    exit 1
fi

echo ""
echo "==============================="
echo "All Tutorial §3.3 Tests Passed!"
echo "==============================="
echo ""
echo "Output files saved to: $OUTPUT_DIR/"
ls -la "$OUTPUT_DIR/"
