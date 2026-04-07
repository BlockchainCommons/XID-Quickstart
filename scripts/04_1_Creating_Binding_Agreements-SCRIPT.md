#!/bin/bash
#
# 04_1_Creating_Binding_Agreements-SCRIPT.sh
#
# Tests all commands from §4.1, verifying:
# - Detached binding agreement
# - Embedded binding agreement
#
# Usage: bash 04_1_Creating_Binding_Agreements-SCRIPT.sh


set -e

echo "=== LEARNING XIDS §4.1: Creating Binding Agreements ==="

# Configuration

# Create output directory

OUTPUT_DIR="output/script-04-1-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUTPUT_DIR"

XID="ur:xid/tpsplftpsplntpsotanshdhdcxnsvelewdmugsjksomhcsdngumosodnlffnlpcxfeylutcseeluatlyihdphyieadoycfaorylftpsplrtpsokseyjoihihjpdpihjtiejljpjkihjnihjtjydpiyjpjljndpieihkojpihkoinihktihjpdpideyeeihehhsieehihemetiyeyehieeeoycfaornlstpsotanshdhdcxhdsfzozcetjkztcmwnvaqzhkdyvlytswpmhttoprrtskioesiyhlkeotjecaknhdoytpsojkjkiaisihjnhsftihjnjojzjlkkihihgmjljzihtpsokscsfdihhsiecxguihiakpjpinjykkcxgdjpjliojphsjnjnihjpoytpsojljkiaisihjnhsftktjljpjejkfgjljptpsojzguinjkjyihjpgujohsiaihjkoycfaorslntpsotanshdhdcxnsvelewdmugsjksomhcsdngumosodnlffnlpcxfeylutcseeluatlyihdphyieadoytpsojsjpihjzhsjyinjljtjkisinjofwhsjkinjktpsoksiaguihiakpjpinjykkcxiajljzjzhsidjljphsjyinjljtcxjohsjpjyjtihjpcxktisjlcxkoihjpiniyinihiecxiajpihieihjtjyinhsjzjkcxjyisjpjlkpioiscxiajljnjninjydpjpihkoihhsjzcxhsjtiecxihjtiajpkkjojyihiecxjkishsjpinjtiooybetpsokoeydyeyendpdyeedpdyemghehehftehecdpehdyftdydyoytpsojpihjtiejljpjkihjnihjtjyfxjljtjyihksjytpsokshghfihjpiyinihiecxjojpihkoinjlkpjkcxjkihiakpjpinjykkcxihksjoihjpinihjtiaihdwcxktjljpjeihiecxjyjlioihjyisihjpcxjljtcxjkisjljpjycxjojpjlimihiajycxiyjljpcxguinjkjyihjpgujohsiaihjkoytpsojljoihihjpfejtiejljpjkihjnihjtjytpsoksguhgjpinjyihjkcxjkihiakpjpihdwcxktihjzjzdpjyihjkjyihiecxiajlieihcxktinjyiscxiajzihhsjpcxhsjyjyihjtjyinjljtcxjyjlcxjojpinkohsiakkdpjojpihjkihjpkoinjtiocxjohsjyjyihjpjtjkoytpsojoihjtiejljpjkihjnihjtjyguiajljoihtpsoksfeguihiakpjpinjykkcxhsjpiaisinjyihiajykpjpihdwcxiajpkkjojyjliojphsjoisiniacxinjnjojzihjnihjtjyhsjyinjljtdwcxjojpinkohsiakkcxjohsjyjyihjpjtjkoyadtpsojehsjyjyihjkjyhsjyinjljtoyaxtpsotansghlfaohdfznbytwmprtoiegsdekihpltdnrtstcnykzcvaenbkjlpejksbhnatlyontkvotpmosodmfsgajtpmielrlgzowpvevlstveadmknetdrkykbachkindwnrdtisalaltaxoycsfzlftpsotngdgmgwhflfaxhdimkscwmkvocnjsswmhkpdstkfhyajzetonlsfxlpsgskltcamefpwsaesptbaakslnamztfhcmfpfylrztndlyftnelkaoflwmbaltzesokbpycnntfxldeecmecttmtjsrdbtgsyleosfwmwfnytodabdfzyneetyoejnpmmodpdsdaflfljliagofdprztvtteotlgdepmbtcylbrnidlfoycsfylftansfwlrhdroimftfnftynlnlklywkgruoltvlcfpdihnbztludwvezmgruybbaodpeofljtfmoyghzslkhdzmwlhfknskpmlpeeiyntaeamdiutfhjlpkgoutptlswptboluyplluluzmtdrevetdutrtttpymeoeynuouyueztsoktsgptrdaeoedmbyhgisgrqdpshtykaaprieaypdkbcyfgdiwmlbftescynybycnfewemdtsiyfpjsldaejlmskokbdmihztjspmkshphfrotlvyoszosfiafgcagettdrnlzcolemrscmryltytmhlsbzcxfgzonlsewfckpltozedrtbbkttfyswtebbjkrkwtcsvdcytddpgsoeoewsashhjztpadzolsvwttgdhkaelsineyinbegmoytodstyzeweesayhddatansfphdcxhgfnuektdlzmaswfayjnyawsrhmukkzendmybzrngohnylbyaagdhptonediesguoybwtpsotanshptansfwlrhdcxrhwlehpemykgemskmhjpuoclfyfpgocwlgskvasrayclzomuvakkghfyflprltwfgsloyksasnmoftftfylyjnamspgdlyhsaektledkmkswzejomsishhbkskhthflfaxtansgmgdwkbglgdidwcftyvepmcplbwkfldwgusnoybstpsotansgmhdcxiyvwcpcptddkeemdwfoylrrnspcttebgsbrnfmoetirfmwehhsrehdpmstdadaytoyaylrtpsotansgylftanshflfaohdcxonbbaxfdchqzlfcptlbbyachdypehyaxtecavlhymnmyceeekotpcamnamguclmotansgrhdcxcsrnchrnrpbsrnuecwaymoihplfnkgrdaxiefgpyidvysecnluhtwlwmpfwndnctoycscstpsoisfwgmhsiekojliaetoycsfncsfglfoycsfplftansfwlrhdghotahvetdfxhdwztemevltdntjzsgberfcnjeyaqdgamnadvelphdptplnnlbjsvwlusajngllobdytvwfrdeemmwurrysewdlndtbtwfchytkbhhlsaymdfemthkihwtrolskshlkbfgatatmszmdyjofhfedkkpjznlidfngsfdtefdftfllyyacxlbylhpahgdyteyctjntnetnlynbzsefywzcxgmlsguhddatansfphdcxjemdmobewtihrohsgaghsglkgepdcmhdflhnamvegwssjzolpsjslesrwypkrydwoybwtpsotanshptansfwlrhdcxdatndeievyfyghdacxclkbchlrftsrkbetimstroasbwctjsynrktnsfryfgwkyagsaskoeejkfegskovyqdfyvwcfgdnbetfzpdclbnftzmlavdprkiptzclyrfhflfaxtansgmgdbsolgdhstncflblukphedwiaytiodtfxoybstpsotansgmhdcxrsfpfpfmldltkbsaamecmogabacsjtdedtsshlmdutaoaoylstndserdwdnedwmnoycfaorylftpsplrtpsokscfhsiaiajlkpjtjydpiajpihieihjtjyinhsjzdpioinjyiskpidoyadtpsojpiyjlhsiyftgwjtjzinjtihfpiaiajlkpjtjyoycfaorsldtpsotanshdhdcxnsvelewdmugsjksomhcsdngumosodnlffnlpcxfeylutcseeluatlyihdphyieadoytpsojsjkjkisguiniojtinjtiogrihkkjkgogmgstpsotpcxksenisjyjyjojkftdldlhsjoindmioinjyiskpiddmiajljndlkpjkihjpjkdlfwgmhsiekojliaetdljkjkishejkiniojtinjtiohejeihkkjkoytpsojoiyjlhsiyfthsiaiajlkpjtjyglhsjnihtpsoisfwgmhsiekojliaetoytpsojnjkjkisguiniojtinjtiogrihkktpsotansgylftanshftanehsksgdjkjkisdpihieeyececehescxfpfpfpfpfxeoglknhsfxehjzhtfygaehglghfeecfpfpfpfpgafdeceyjlgogmjehkkpjpjtihiygojtjlfgiddnfpgsjpjpfxeedlhdihdngdkpgwgmfxfgkninjlgmfyhfjkgmtansgrhdcxfhtkhnmyoeoyvdvdgolosrpfrosnrsaycmiycelnqdjyjzlplpeykgesmnvwoeimoytpsokscwiyjlhsiyfthsiaiajlkpjtjyguihjpkoiniaihfdjljnihjohsioihtpsotpcxksdkisjyjyjojkftdldlioinjyiskpiddmiajljndlfwgmhsiekojliaetdlfwgmhsiekojliaetoycscwtpsotpcxksdaisjyjyjojkftdldlhsjoindmioinjyiskpiddmiajljndlkpjkihjpjkdlfwgmhsiekojliaetoycseetpsotpcxjpisjyjyjojkftdldlioinjyiskpiddmiajljnoytpsojsjkjkisguiniojtinjtiogrihkkghihksjytpsoksgdjkjkisdpihieeyececehescxfpfpfpfpfxeoglknhsfxehjzhtfygaehglghfeecfpfpfpfpgafdeceyjlgogmjehkkpjpjtihiygojtjlfgiddnfpgsjpjpfxeedlhdihdngdkpgwgmfxfgkninjlgmfyhfjkgmoybetpsokoeydyeyendpdyeedpdyehgheheefteeetdpehdyftdydyoycfaorntpsotanshdhdcxnsvelewdmugsjksomhcsdngumosodnlffnlpcxfeylutcseeluatlyihdphyieadoyaxtpsotansghtaneidkkaddmdpdpdpdpdpfwfeflgaglcxgugufdcxgugaflglfpghgogmfedpdpdpdpdpbkgoehglgagodyjzfdfpfpfpfpfpgyfpfpfpfygtfpfpfpfpgsiaeogljlgshghfjegtimgoehgtghjefpfpfpfpioiyjthsisgmflgminenkpieecesguihiohfkoeefpkpkpjkgsimesbkieemeedneeecfegahdgwgrisfeglhgksfefpfpfpfpgahthgeceyhthgkskoiaflgofpfpfpfpfpfpfpfpfpfwjtgljlhkghgaehgliofpfpfpfggtfpfpfpfpgsiaeogljlgshghfjebkgtimgoehgtghjefpfpfpfwfphkihjeidkpjofxetihiyiejegejzgmeefdkkjpfyjkksgufljlghgtesdleejofdjegsjkghemdletgriygwhskoisecfgjtkkgmemfwkpgyeedlgwfwbkkkgufxghgrghkkhfenghiheefgeofdknhshfjtdldnjyehgwfyfefwiofsfsbkdpdpdpdpdpfeglfycxgugufdcxgugaflglfpghgogmfedpdpdpdpdpbkoyaylrtpsotansgylftanshflfaohdcxplvdotinmnwensttrtlrtiisqzehrltlnlguhdludywzsebztnqdndwztpdazeqdtansgrhdcxfmlpjkhspautsfmwlndrpavobwpyotsazsdidwrnrpcylfintnwtgrnnhdhhpyjpoycscstpsojlhsjyjyihjkjyhsjyinjljtdpjeihkklfoycsfplftansfwlrhdghzerhzmwmropewflucyzemsndrosbtbzeendnlgrtdlfdrniaztlbpmqdgrjpkeathloessrkhprfbkbyasglkbfdkgaarfmojlecykatdketzshfuymwdeguiypkfhmkzehhinlageiaenrldybbdrlsnybaatdycputiyttgsdwrktygywffdkofyfwjeutdegdwymhdkcmlyhflyoxyaverfahvsfhcagohddatansfphdcxiopakburhprngowmtshlrswzihbytpflgtrootzosfrpnnfprymuveasenotaeadoybwtpsotanshptansfwlrhdcxsoynzofprpdatycheouehywtvtbwwkfdhkrkfywkwmfdihsfsphkbbwpytmsmwjzgsvwqdhnplwttkjsesknytbbtngdkebwwyjnhdzojswevshpamwyvthsltkohflfaxtansgmgdvapytkndaxwlselynstayndmqdchfsdioybstpsotansgmhdcxghchykwlghoxpftljectmyyldyamgycwamfwbnsbjelbsshkbzcnuttyrltlwtgmoycsfncsfdoyaxtpsotansghlfaohdfztnaesngaayrhetnbfrbzvybninzstbbnrlbwnlkgrllefmsffhskcafsprmejnonihhtiydtdehnjorspdahzoidpamupdlfyahsuowniafsskmhrtytpkfljocmksaxfdondpto"


XID_ID=$(envelope xid id $XID)
PASSWORD="test-password-for-tutorial"

echo ""
echo "Step 1: Create a Purpose-Specific Contract Key"
echo "=============================================="

CONTRACT_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
CONTRACT_PUBKEYS=$(envelope generate pubkeys "$CONTRACT_PRVKEYS")

if [ "$CONTRACT_PRVKEYS" -a "$CONTRACT_PUBKEYS" ]
then
  echo "✅ Contract-signing key created (limited to signing only)"
else
    echo "❌ Failed to create contarct-signing keys"
    exit 1;
fi

echo ""
echo "Step 2: Register Contract Key in XID"
echo "===================================="

XID_WITH_CONTRACT_KEY=$(envelope xid key add \
    --verify inception \
    --nickname "contract-key" \
    --allow sign \
    --private encrypt \
    --encrypt-password "$PASSWORD" \
    "$CONTRACT_PRVKEYS" \
    "$XID")

if envelope format "$XID_WITH_CONTRACT_KEY" | grep -q "contract-key"
then
  echo "✅ Added contract-signing key to XID"
else
    echo "❌ Failed to add contract-signing key to XID"
    exit 1;
fi

echo ""
echo "Viewing all keys in XID:"
echo ""
read -a KEYLIST <<< $(envelope xid key all "$XID_WITH_CONTRACT_KEY")
for i in "${KEYLIST[@]}"
  do
    envelope format $i
    echo ""
done

echo "Step 3: Publish New XID"
echo "======================="

XID_WITH_CONTRACT_KEY=$(envelope xid provenance next \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$XID_WITH_CONTRACT_KEY")
echo "✅ Provenance advanced"

PUBLIC_XID_WITH_CONTRACT_KEY=$(envelope xid export --private elide --generator elide "$XID_WITH_CONTRACT_KEY")

echo "$CONTRACT_PRVKEYS" > $OUTPUT_DIR/01-contract-keys.ur
echo "$XID_WITH_CONTRACT_KEY" > $OUTPUT_DIR/02-bradvoc8-xid-private.envelope
echo "$PUBLIC_XID_WITH_CONTRACT_KEY" > $OUTPUT_DIR/03-bradvoc8-xid-public.envelope

echo ""
echo "Step 4: Create Ben's Identity"
echo "============================="

BEN_PASSWORD="bens-own-password"
BEN_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
BEN_PUBKEYS=$(envelope generate pubkeys "$BEN_PRVKEYS")
BEN_XID=$(echo $BEN_PRVKEYS | \
    envelope xid new \
    --private encrypt \
    --encrypt-password "$BEN_PASSWORD" \
    --nickname "Ben (SisterSpaces)" \
    --generator encrypt \
    --sign inception)
BEN_XID_ID=$(envelope xid id "$BEN_XID")

if [ $BEN_XID_ID ]
then
    echo "✅ Ben's XID created: $BEN_XID_ID"
else
    echo "❌ Failed to create Ben's XID"
    exit 1;
fi

echo "$BEN_XID" > $OUTPUT_DIR/04-ben-xid-private.envelope

echo ""
echo "Step 5: Create the CLA Document"
echo "==============================="

curl -q https://www.apache.org/licenses/LICENSE-2.0.txt > $OUTPUT_DIR/05-license-apache.txt

if [ ! -f $OUTPUT_DIR/05-license-apache.txt ]
then
    echo "❌ Was not able to download Apache license"
    exit 1;
fi    

shasum -a 256 $OUTPUT_DIR/05-license-apache.txt > $OUTPUT_DIR/06-license-apache-hash.txt

read hash filename < $OUTPUT_DIR/06-license-apache-hash.txt

# Creating Licensing Object

LICENSE=$(envelope subject type string "Apache-2.0")
LICENSE=$(envelope assertion add pred-obj known 'dereferenceVia' string "https://www.apache.org/licenses/LICENSE-2.0.txt" $LICENSE)
LICENSE=$(envelope assertion add pred-obj known 'date' string "2004-01-00T00:00-00:00" $LICENSE)
LICENSE=$(envelope assertion add pred-obj string "contractHash" string $hash $LICENSE)
LICENSE=$(envelope assertion add pred-obj string "hashAlgorithm" string "shasum256" $LICENSE)

# Creating Project Manager Object

PM=$(envelope subject type ur $BEN_XID_ID)
PM=$(envelope assertion add pred-obj known 'nickname' string "Ben (SisterSpaces)" $PM)

# Creating Contributor Object

CONTRIBUTOR=$(envelope subject type ur $XID_ID)
CONTRIBUTOR=$(envelope assertion add pred-obj known 'nickname' string "BRadvoc8" $CONTRIBUTOR)

# Building the Top Level CLA

CLA=$(envelope subject type string "Individual Contributor License Agreement")
CLA=$(envelope assertion add pred-obj string "project" string "SisterSpaces SecureAuth Library" "$CLA")

# Adding Grants and Representations

CLA=$(envelope assertion add pred-obj known isA string "ContributorLicenseAgreement" "$CLA")
CLA=$(envelope assertion add pred-obj string "grantsCopyrightLicense" string "perpetual, worldwide, non-exclusive, royalty-free" "$CLA")
CLA=$(envelope assertion add pred-obj string "grantsPatentLicense" string "for contributions containing patentable technology" "$CLA")
CLA=$(envelope assertion add pred-obj string "contributorRepresents" string "original work with authority to grant license" "$CLA")

# Adding Sub Envelopes

CLA=$(envelope assertion add pred-obj string "licenseType" envelope "$LICENSE" "$CLA")
CLA=$(envelope assertion add pred-obj string "projectManager" envelope "$PM" "$CLA")
CLA=$(envelope assertion add pred-obj string "contributor" envelope "$CONTRIBUTOR" "$CLA")

if [ $CLA ]
then
    echo "✅ CLA document created:"
else
    echo "❌ Failed to create CLA"
    exit 1
fi

echo ""
envelope format "$CLA"

echo ""
echo "Step 6: Sign with a Contract Key"
echo "==============================="

CLA_WITH_DATE=$(envelope assertion add pred-obj known 'date' string `date -Iminutes` "$CLA")
WRAPPED_CLA=$(envelope subject type wrapped $CLA_WITH_DATE)
SIGNED_CLA=$(envelope sign --signer "$CONTRACT_PRVKEYS" "$WRAPPED_CLA")

echo ""
echo "Step 7: Verify CLA"
echo "=================="

success=0
read -a PUBKEY <<< $(envelope xid key all "$PUBLIC_XID_WITH_CONTRACT_KEY")
for i in "${PUBKEY[@]}"
  do
    if envelope verify -v $i $SIGNED_CLA >/dev/null 2>&1; then
      echo "✅ One of the signatures verified! "
      echo $i
      success=1
    fi
done

if [ ! $success ]
then   
   echo "❌ None of the public keys verified against the signature"
fi

echo ""
echo "Step 8: Accept & Record"
echo "========================"

    
WRAPPED_SIGNED_CLA=$(envelope subject type wrapped "$SIGNED_CLA")
ACCEPTED_CLA=$(envelope assertion add pred-obj string "acceptedBy" ur $BEN_XID_ID "$WRAPPED_SIGNED_CLA")
ACCEPTED_CLA=$(envelope assertion add pred-obj known 'date' string `date -Iminutes` "$ACCEPTED_CLA")
WRAPPED_ACCEPTED_CLA=$(envelope subject type wrapped "$ACCEPTED_CLA")
SIGNED_ACCEPTED_CLA=$(envelope sign --signer "$BEN_PRVKEYS" "$WRAPPED_ACCEPTED_CLA")

echo "✅ CLA accepted"
envelope format $SIGNED_ACCEPTED_CLA

echo "$SIGNED_CLA" > $OUTPUT_DIR/07-cla-signed.envelope
echo "$SIGNED_ACCEPTED_CLA" > $OUTPUT_DIR/08-cla-accepted.envelope

echo ""
echo "==============================="
echo "All Tutorial §4.1 Tests Passed!"
echo "==============================="
echo ""
echo "Output files saved to: $OUTPUT_DIR/"
ls -la "$OUTPUT_DIR/"
