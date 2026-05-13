#!/bin/bash
# 05_1_Generating_Operational_Keys-SCRIPT.sh
#
# Tests all commands from §5.1, verifying:
# - Production of XID with operational keys 
# - Production of XID without management keys
#
# Usage: bash 05_1_Generating_Operational_Keys-SCRIPT.sh

set -e

echo "=== LEARNING XIDS §5.1: Generating Operational Keys ==="

# Configuration

# Create output directory

OUTPUT_DIR="output/script-05-1-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUTPUT_DIR"

XID="ur:xid/tpsplftpsplotpsotanshdhdcxnsvelewdmugsjksomhcsdngumosodnlffnlpcxfeylutcseeluatlyihdphyieadoycsfzlftpsotngdgmgwhflfaxhdimwzaonnwfaatsuyghmhihlswmfrosdwwsfxcmktferekosbmsemdmhfgefscwoxsozcdmjtbkrfssonfpbatlcxcsotgrkebazekolrrkoxnsbamwcapkghrtkkgrbteyfngachghoximvafgfnknwnfzpththgoxlfoytycklofzmsfwgszmcybddsishpmnfycfpraetetasszsaysnlfoycsfylftansfwlrhdrolnwezmaekkaoytdnfmpemtpednmuoxkstsonhfplcpihgmptvyihdwdwzehhbsvlykcfnllbnnvsoyylryrychvtdaknkkbnaxknwednihospdynsbsszoqdbtfwneglweiasbbydeonhgvoknzmvsttqdwezelbrkolbeeotyvtwkdktnlyontddlaardlshgdtbthgwtdlfmrdrojnkiwndadlnnfnuofhghwkwflkjyembbcennjeprykiedmcfhpzsnsmdidfdnyzopswklkbkwzlsfzfhdpbkfdjzsbishgcxcncfatwecetefyjzpmwndlzcfsgdbagtytftutahltzcntecbeimgrfldlnbdagsbztprtpejoglcniychlesnoegdvtgmrtotcwkttnhyihqzrnprflreislyhddatansfphdcxaodksppteeaxgmtdrlsktartdmmyrtmkinjemwaehyaarpdkbgsafzkbfxkkeelyoybwtpsotanshptansfwlrhdcxvtynfetlfwaotaiabakpvylsctsrpmadtlbwcsglgrgerehhtbbsbamkkendfpzmgspkltfsmslgjpmevtgtryttgygdhgaelsbawftpcmbdptjycpjkynuornryhflfaxtansgmgdzslogwemtlgdskwysahfktdktlswgawzoybstpsotansgmhdcxiyvwcpcptddkeemdwfoylrrnspcttebgsbrnfmoetirfmwehhsrehdpmstdadaytoyaylrtpsotansgylftanshflfaohdcxplvdotinmnwensttrtlrtiisqzehrltlnlguhdludywzsebztnqdndwztpdazeqdtansgrhdcxfmlpjkhspautsfmwlndrpavobwpyotsazsdidwrnrpcylfintnwtgrnnhdhhpyjpoycscstpsojlhsjyjyihjkjyhsjyinjljtdpjeihkkoycsfncsfdlfoycsfplftansfwlrhdghgdttmediksttnsdiynatqzdelpvtsbsshleyglnyeetajlglsbgwjsgwvotyylzmkbolisbsfyihcseebyhhttcthnahctgomyveutktdkbsfxglgsylvevlasoezmwnlrdnspjtfsayglpfknvonyskgllgetckjybdsbrhgswplkbatyisrkcetnvshtcydwgdwdtigymogrnylfongyhluevwcpbnpsvehddatansfphdcxiopakburhprngowmtshlrswzihbytpflgtrootzosfrpnnfprymuveasenotaeadoybwtpsotanshptansfwlrhdcxlknlrtesrlptbbztlbuenlayoevyuoynetylttrofgsguomncfzmuoderlbyjzcfgstkgmfysachglbsjylatlykmkgdjyceiyylkegyzskneolntejzdplesefdhflfaxtansgmgdkngelnkkuorskthlgutscnpfgtasgodeoybstpsotansgmhdcxghchykwlghoxpftljectmyyldyamgycwamfwbnsbjelbsshkbzcnuttyrltlwtgmoycfaorylftpsplrtpsokscfhsiaiajlkpjtjydpiajpihieihjtjyinhsjzdpioinjyiskpidoyadtpsojpiyjlhsiyftgwjtjzinjtihfpiaiajlkpjtjyoycfaorsldtpsotanshdhdcxnsvelewdmugsjksomhcsdngumosodnlffnlpcxfeylutcseeluatlyihdphyieadoytpsojsjkjkisguiniojtinjtiogrihkkjkgogmgstpsotpcxksenisjyjyjojkftdldlhsjoindmioinjyiskpiddmiajljndlkpjkihjpjkdlfwgmhsiekojliaetdljkjkishejkiniojtinjtiohejeihkkjkoytpsojoiyjlhsiyfthsiaiajlkpjtjyglhsjnihtpsoisfwgmhsiekojliaetoytpsojnjkjkisguiniojtinjtiogrihkktpsotansgylftanshftanehsksgdjkjkisdpihieeyececehescxfpfpfpfpfxeoglknhsfxehjzhtfygaehglghfeecfpfpfpfpgafdeceyjlgogmjehkkpjpjtihiygojtjlfgiddnfpgsjpjpfxeedlhdihdngdkpgwgmfxfgkninjlgmfyhfjkgmtansgrhdcxfhtkhnmyoeoyvdvdgolosrpfrosnrsaycmiycelnqdjyjzlplpeykgesmnvwoeimoytpsokscwiyjlhsiyfthsiaiajlkpjtjyguihjpkoiniaihfdjljnihjohsioihtpsotpcxksdkisjyjyjojkftdldlioinjyiskpiddmiajljndlfwgmhsiekojliaetdlfwgmhsiekojliaetoycscwtpsotpcxksdaisjyjyjojkftdldlhsjoindmioinjyiskpiddmiajljndlkpjkihjpjkdlfwgmhsiekojliaetoycseetpsotpcxjpisjyjyjojkftdldlioinjyiskpiddmiajljnoytpsojsjkjkisguiniojtinjtiogrihkkghihksjytpsoksgdjkjkisdpihieeyececehescxfpfpfpfpfxeoglknhsfxehjzhtfygaehglghfeecfpfpfpfpgafdeceyjlgogmjehkkpjpjtihiygojtjlfgiddnfpgsjpjpfxeedlhdihdngdkpgwgmfxfgkninjlgmfyhfjkgmoybetpsokoeydyeyendpdyeedpdyehgheheefteeetdpehdyftdydyoycfaorntpsotanshdhdcxnsvelewdmugsjksomhcsdngumosodnlffnlpcxfeylutcseeluatlyihdphyieadoyaxtpsotansghtaneidkkaddmdpdpdpdpdpfwfeflgaglcxgugufdcxgugaflglfpghgogmfedpdpdpdpdpbkgoehglgagodyjzfdfpfpfpfpfpgyfpfpfpfygtfpfpfpfpgsiaeogljlgshghfjegtimgoehgtghjefpfpfpfpioiyjthsisgmflgminenkpieecesguihiohfkoeefpkpkpjkgsimesbkieemeedneeecfegahdgwgrisfeglhgksfefpfpfpfpgahthgeceyhthgkskoiaflgofpfpfpfpfpfpfpfpfpfwjtgljlhkghgaehgliofpfpfpfggtfpfpfpfpgsiaeogljlgshghfjebkgtimgoehgtghjefpfpfpfwfphkihjeidkpjofxetihiyiejegejzgmeefdkkjpfyjkksgufljlghgtesdleejofdjegsjkghemdletgriygwhskoisecfgjtkkgmemfwkpgyeedlgwfwbkkkgufxghgrghkkhfenghiheefgeofdknhshfjtdldnjyehgwfyfefwiofsfsbkdpdpdpdpdpfeglfycxgugufdcxgugaflglfpghgogmfedpdpdpdpdpbkoycfaorylftpsplrtpsokscxjojpjlimihiajydpjkinjkjyihjpdpjkjohsiaihjkdpjkihiakpjpihhskpjyisoycfaorslrtpsotanshdhdcxnsvelewdmugsjksomhcsdngumosodnlffnlpcxfeylutcseeluatlyihdphyieadoytpsoiniajzhsfyinioihjkjytpsotansfphdcxhkrsoyhnoyuodrnsjewsylmybwmouonbtkglbbaxyakilfmnlaptpkjkiepszsdmoycscwtpsoksesisjyjyjojkftdldlioinjyiskpiddmiajljndlguinjkjyihjpgujohsiaihjkdlguihiakpjpihfpkpjyisdlfxgsfpjkdlgmfefpfygtfedmjnieoytpsojziyjlhsiyftgdjpjlimihiajytpsojzguinjkjyihjpgujohsiaihjkoyadtpsojziyjlhsiyftgdjpjlimihiajyoycfaorntpsotanshdhdcxnsvelewdmugsjksomhcsdngumosodnlffnlpcxfeylutcseeluatlyihdphyieadoyaxtpsotansghlfaohdfzmtiniolbreytcnyncnwmsoeyvtlkwzjzprlupebbbzghdnmnoyprenmdlflucaonsffelpfehkaaiyguzttartsfhdvtwfwdsboxfdlfbtwmwekbimdtemftatmhttbsoyaylrtpsotansgylftanshflfaohdcxonbbaxfdchqzlfcptlbbyachdypehyaxtecavlhymnmyceeekotpcamnamguclmotansgrhdcxcsrnchrnrpbsrnuecwaymoihplfnkgrdaxiefgpyidvysecnluhtwlwmpfwndnctoycscstpsoisfwgmhsiekojliaetoycsfncsfglfoycsfplftansfwlrhdghjssfiodtwtqzzsvlntfxbandcykkemykchpshdsgfsgsmtinjzynrhaddejthpcntbiddwjelfldisfrhdkeselggsttdikgonlapehefpdaditkadghatpeflamqdfmdsvdmtwmjpcamoimgozohfhsrlpmsetdkgdrcttogsehwmjldmjptejymsytglhtwegdfrfmrtvtcnrlcasfzmspbtvofwpdvdmuhddatansfphdcxjemdmobewtihrohsgaghsglkgepdcmhdflhnamvegwssjzolpsjslesrwypkrydwoybwtpsotanshptansfwlrhdcxytflrhwzbgzcsrfyrptygesrdspttbjlvtnblrtybnmefxdyotehaatkhkpklpiegshdtkhlresersnlrtcafmfxtigdteaosbbazstymoftcwtlesrohhgoidpdhflfaxtansgmgdtnmhzetttnbzskcntlvlwtreytmtndfroybstpsotansgmhdcxrsfpfpfmldltkbsaamecmogabacsjtdedtsshlmdutaoaoylstndserdwdnedwmnoycfaorylftpsplrtpsokseyjoihihjpdpihjtiejljpjkihjnihjtjydpiyjpjljndpieihkojpihkoinihktihjpdpeeehiaeshsenieehidehhseyihiyesenoycfaornlstpsotanshdhdcximprmsaylgfwcyjzzcamzmdrbdetjsrngamnbsfptbwtksihrhzonsahuthydwtboytpsojkjkiaisihjnhsftihjnjojzjlkkihihgmjljzihtpsokscsfdihhsiecxguihiakpjpinjykkcxgdjpjliojphsjnjnihjpoytpsojljkiaisihjnhsftktjljpjejkfgjljptpsojzguinjkjyihjpgujohsiaihjkoycfaorslntpsotanshdhdcxhecefsnnionspljpftktetwymnfmcyecveuotktpwenlhyhdpmpykpchcmzchywzoytpsojpihjtiejljpjkihjnihjtjyfxjljtjyihksjytpsoksglhfihjpiyinihiecxjojpihkoinjlkpjkcxihksjoihjpinihjtiaihdwcxktjljpjeihiecxjyjlioihjyisihjpcxjljtcxjkisjljpjycxjojpjlimihiajycxiyjljpcxguinjkjyihjpgujohsiaihjkoybetpsokoeydyeyendpdyeedpdyehghdyetfteyecdpehdyftdydyoytpsojsjpihjzhsjyinjljtjkisinjofwhsjkinjktpsoksiaguihiakpjpinjykkcxiajljzjzhsidjljphsjyinjljtcxjohsjpjyjtihjpcxktisjlcxkoihjpiniyinihiecxiajpihieihjtjyinhsjzjkcxjyisjpjlkpioiscxiajljnjninjydpjpihkoihhsjzcxhsjtiecxihjtiajpkkjojyihiecxjkishsjpinjtiooytpsojljoihihjpfejtiejljpjkihjnihjtjytpsoksguhgjpinjyihjkcxjkihiakpjpihdwcxktihjzjzdpjyihjkjyihiecxiajlieihcxktinjyiscxiajzihhsjpcxhsjyjyihjtjyinjljtcxjyjlcxjojpinkohsiakkdpjojpihjkihjpkoinjtiocxjohsjyjyihjpjtjkoytpsojoihjtiejljpjkihjnihjtjyguiajljoihtpsoksfeguihiakpjpinjykkcxhsjpiaisinjyihiajykpjpihdwcxiajpkkjojyjliojphsjoisiniacxinjnjojzihjnihjtjyhsjyinjljtdwcxjojpinkohsiakkcxjohsjyjyihjpjtjkoyadtpsojehsjyjyihjkjyhsjyinjljtoyaxtpsotansghlfaohdfzbzfslnetykknhplpwmhhcmcnwtfrwftogtrdadjtaxbsjkptmsmesbotldcstngyteisfhrntecemkoxtpueinjtmtfdrtvebwvtasbdcxeclafphthtfylfhgrhlabnoyaylrtpsotansgylftanshflfaohdcxlumegtzorkdntkrolkosmyrffndiwkrofhbblfzerodipahhkkcejtatinbsjtintansgrhdcxlnjzbnfwasfshtfgvehhktdschdwttrtctdepkbyhlhkbdsogwashkgobsqzgwjtlfoycsfplftansfwlrhdgheswkfykbhdbgpaplgulrcnwzktmwzcdwdkjtutclwfkekspkcwykcehhnswdwzlbwppsfsvthkvwfnrplgfrbkndfxktmdmdletpaonlnbuekesswketfyjpayzsskkgmyjshemkoydrayotltwmflaassgydmialninswkpgsaahftarfeycamneyhgwmmsjlgdwloydkzoeejehdeewemycnbdbnvagdrphddatansfphdcxayhkjpidzehpytiesnkofybgbbinntaezozstbctideyykdsbzylimwsvadplnlaoybwtpsotanshptansfwlrhdcxjkdmjsweadylbtdeesbyhkjtaxlbahreguetjowzjstkfpdkfrtleopfgtlsbkbegsylhfvolakkmnksrljypfzosngdfntygyldbsynhhlpuycmjsuraseoktrnhflfaxtansgmgdmennrfiozehsbtwynnfwmejsbzgaknstoybstpsotansgmhdcxyaflntkectinioyttklocelbmhaseswnoeetdmtprnfmytmyhfghimjzhebnctftoycscstpsojziajljtjyjphsiajydpjeihkkoycsfncsfdoyaxtpsotansghlfaohdfzpmsnwflnctaosslndseshsrdlnskwesalefemwrsihvtlobtnslaisvehljpmulkpstbsnlbbtwkoedpmhsouramaywknletlbwkrekestvafsgogetoiadidicaloaevtqdrsgy"

XID_ID=$(envelope xid id $XID)
PASSWORD="test-password-for-tutorial"

echo ""
echo "Step 1: Listing Keys"
echo "===================="

echo "Amira's XID key count:"
envelope xid key count $XID

echo ""
echo "Amira's XID keys:"
envelope xid key all $XID

echo ""
echo "Step 2: Check Current Key Permissions"
echo "====================================="

echo "Amira's XID key permissions:"
read -a KEYLIST <<< $(envelope xid key all "$XID")
for i in "${KEYLIST[@]}"
  do
    envelope format $i
done

echo ""
echo "Step 3: Generate a Laptop XID Key"
echo "================================="

LAPTOP_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
LAPTOP_PUBKEYS=$(envelope generate pubkeys "$LAPTOP_PRVKEYS")

if [ "$LAPTOP_PRVKEYS" ]
then   
    echo "✅ Generated laptop operational key"
else
    echo "❌ Failed to generate laptop operational key"
    exit 1;
fi

echo ""
echo "Step 4: Add Key with Limited Permissions"
echo "========================================"

XID_WITH_OPERATIONAL_KEY_1=$(envelope xid key add \
    --verify inception \
    --nickname "laptop-key" \
    --allow auth \
    --allow sign \
    --allow encrypt \
    --allow elide \
    --allow issue \
    --allow access \
    --private encrypt \
    --encrypt-password "$PASSWORD" \
    "$LAPTOP_PRVKEYS" \
    "$XID")

if envelope format "$XID_WITH_OPERATIONAL_KEY_1" | grep -q "laptop-key"
then
  echo "✅ Added operational (laptop) key to XID"
else
    echo "❌ Failed to add laptop key to XID"
    exit 1;
fi

echo ""
echo "Step 6: Add a Portable Drive XID Key"
echo "===================================="

PORTABLE_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
PORTABLE_PUBKEYS=$(envelope generate pubkeys "$LAPTOP_PRVKEYS")

if [ "$PORTABLE_PRVKEYS" ]
then   
    echo "✅ Generated portable operational key"
else
    echo "❌ Failed to generate portable operational key"
    exit 1;
fi

XID_WITH_OPERATIONAL_KEY_2=$(envelope xid key add \
    --nickname "portable-key" \
    --allow auth \
    --allow sign \
    --allow elide \
    --allow access \
    --private encrypt \
    --encrypt-password "$PASSWORD" \
    "$PORTABLE_PRVKEYS" \
    "$XID_WITH_OPERATIONAL_KEY_1")

if envelope format "$XID_WITH_OPERATIONAL_KEY_2" | grep -q "portable-key"
then
    echo "✅ Added operational (portable) key to XID"
else
    echo "❌ Failed to add portable key to XID"
    exit 1;
fi

echo ""
echo "Step 7: Review and Store"
echo "========================"

XID_WITH_KEYS=$(envelope xid provenance next \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$XID_WITH_OPERATIONAL_KEY_2")
PUBLIC_XID_WITH_KEYS=$(envelope xid export --private elide --generator elide "$XID_WITH_KEYS")

echo "✅ Provenance advanced"

echo "$LAPTOP_PRVKEYS" > $OUTPUT_DIR/01-laptop-keys.ur
echo "$PORTABLE_PRVKEYS" > $OUTPUT_DIR/02-portable-keys.ur
echo "$XID_WITH_KEYS" > $OUTPUT_DIR/03-bradvoc8-xid-private.envelope
echo "$PUBLIC_XID_WITH_KEYS" > $OUTPUT_DIR/04-bradvoc8-xid-public.envelope

echo ""
echo "Step 8: Store Your Inception Key"
echo "================================"

INCEPTION_PRVKEYS=$(envelope xid key find inception --private --password "$PASSWORD" $XID_WITH_KEYS)

if [ "$INCEPTION_PRVKEYS" ]
then   
    echo "✅ Extracted inception key"
else
    echo "❌ Failed to extract inception key"
    exit 1;
fi

echo "$INCEPTION_PRVKEYS" > $OUTPUT_DIR/05-inception-keys.ur

echo ""
echo "Step 9: Elide Your Inception Key"
echo "================================"

INCEPTION_PRVKEYS=$(envelope xid key find inception $XID_WITH_KEYS)
INCEPTION_DIGEST=$(envelope digest $INCEPTION_PRVKEYS)
OPERATIONAL_XID=$(envelope elide removing $INCEPTION_DIGEST $XID_WITH_KEYS)

if envelope format "$XID_WITH_OPERATIONAL_KEY_2" | grep -q "BRadvoc8"
then   
    echo "✅ Produced Operational XID"
else
    echo "❌ Failed to elide inception key from XID"
    exit 1;
fi

echo "$OPERATIONAL_XID" > $OUTPUT_DIR/06-bradvoc8-xid-operational.envelope

echo ""
echo "==============================="
echo "All Tutorial §5.1 Tests Passed!"
echo "==============================="
echo ""
echo "Output files saved to: $OUTPUT_DIR/"
ls -la "$OUTPUT_DIR/"
