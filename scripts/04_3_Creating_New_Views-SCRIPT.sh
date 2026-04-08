#!/bin/bash
# 04_3_Creating_New_Views-SCRIPT.sh
#
# Tests all commands from §4.3, verifying:
# - Removing a top-level object from a XID.
# - Removing a lower-level object from a XID.
#
# Usage: bash 04_3_Creating_New_Views-SCRIPT.sh


set -e

echo "=== LEARNING XIDS §4.3: Creating New Views ==="

# Configuration

# Create output directory

OUTPUT_DIR="output/script-04-3-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUTPUT_DIR"

XID="ur:xid/tpsplftpsplotpsotanshdhdcxnsvelewdmugsjksomhcsdngumosodnlffnlpcxfeylutcseeluatlyihdphyieadoycfaorylftpsplrtpsokseyjoihihjpdpihjtiejljpjkihjnihjtjydpiyjpjljndpieihkojpihkoinihktihjpdpideyeeihehhsieehihemetiyeyehieeeoycfaornlstpsotanshdhdcxhdsfzozcetjkztcmwnvaqzhkdyvlytswpmhttoprrtskioesiyhlkeotjecaknhdoytpsojkjkiaisihjnhsftihjnjojzjlkkihihgmjljzihtpsokscsfdihhsiecxguihiakpjpinjykkcxgdjpjliojphsjnjnihjpoytpsojljkiaisihjnhsftktjljpjejkfgjljptpsojzguinjkjyihjpgujohsiaihjkoycfaorslntpsotanshdhdcxnsvelewdmugsjksomhcsdngumosodnlffnlpcxfeylutcseeluatlyihdphyieadoytpsojsjpihjzhsjyinjljtjkisinjofwhsjkinjktpsoksiaguihiakpjpinjykkcxiajljzjzhsidjljphsjyinjljtcxjohsjpjyjtihjpcxktisjlcxkoihjpiniyinihiecxiajpihieihjtjyinhsjzjkcxjyisjpjlkpioiscxiajljnjninjydpjpihkoihhsjzcxhsjtiecxihjtiajpkkjojyihiecxjkishsjpinjtiooybetpsokoeydyeyendpdyeedpdyemghehehftehecdpehdyftdydyoytpsojpihjtiejljpjkihjnihjtjyfxjljtjyihksjytpsokshghfihjpiyinihiecxjojpihkoinjlkpjkcxjkihiakpjpinjykkcxihksjoihjpinihjtiaihdwcxktjljpjeihiecxjyjlioihjyisihjpcxjljtcxjkisjljpjycxjojpjlimihiajycxiyjljpcxguinjkjyihjpgujohsiaihjkoytpsojljoihihjpfejtiejljpjkihjnihjtjytpsoksguhgjpinjyihjkcxjkihiakpjpihdwcxktihjzjzdpjyihjkjyihiecxiajlieihcxktinjyiscxiajzihhsjpcxhsjyjyihjtjyinjljtcxjyjlcxjojpinkohsiakkdpjojpihjkihjpkoinjtiocxjohsjyjyihjpjtjkoytpsojoihjtiejljpjkihjnihjtjyguiajljoihtpsoksfeguihiakpjpinjykkcxhsjpiaisinjyihiajykpjpihdwcxiajpkkjojyjliojphsjoisiniacxinjnjojzihjnihjtjyhsjyinjljtdwcxjojpinkohsiakkcxjohsjyjyihjpjtjkoyadtpsojehsjyjyihjkjyhsjyinjljtoyaxtpsotansghlfaohdfznbytwmprtoiegsdekihpltdnrtstcnykzcvaenbkjlpejksbhnatlyontkvotpmosodmfsgajtpmielrlgzowpvevlstveadmknetdrkykbachkindwnrdtisalaltaxoyaylrtpsotansgylftanshflfaohdcxlumegtzorkdntkrolkosmyrffndiwkrofhbblfzerodipahhkkcejtatinbsjtintansgrhdcxlnjzbnfwasfshtfgvehhktdschdwttrtctdepkbyhlhkbdsogwashkgobsqzgwjtlfoycsfplftansfwlrhdghghzceetljywzehjedwzewkaopezocwknhldrqdmystghwtoltyfmcnkpfyrpuocygwpmrlnlmnadfxjorfbyvekepfylwkfmspbktladrtmyrnswbagywlcxdtasplnbreztdawkgycmtyvtdejtplgmosrprocwesmesttdgsjkcsbgzoondwaxtyktglweesgdsnaypddnmhsbsaeytdzsvwfymklrpyeyhddatansfphdcxayhkjpidzehpytiesnkofybgbbinntaezozstbctideyykdsbzylimwsvadplnlaoybwtpsotanshptansfwlrhdcxvyvymhveuyrliodsgmnlgykndtrtpslfkoktoyfheojndnkkmktkwnfejzqzkketgsjtskmujeqduymeahhfsbatbzgdeywtsgrdjejtjtdkglasytzehhtawezshflfaxtansgmgdaekkytjzwmlfhlaomhsagswzaetdhttdoybstpsotansgmhdcxyaflntkectinioyttklocelbmhaseswnoeetdmtprnfmytmyhfghimjzhebnctftoycscstpsojziajljtjyjphsiajydpjeihkkoycsfncsfdoycsfzlftpsotngdgmgwhflfaxhdimutwyskfwihlagwoxhytdrtrngtdwmujobgmsdrfpehdroetibnttndoscydwrhtomkrkknutcfhynntsqzmthtoecaclhkhksgpdhlkpcyfgievwktuepmrtatrpotecsrtkmohdhdfpgltpgykphkknmtcnbapmpdrooxfhwfpklkoeosgapylgdkonwzfpvlremubnztghftgszslslfoycsfylftansfwlrhdrofpmddpengdnsvyhemtgumeteasbsnnrppfdehkdlpdgygoskselrjnfxwzasditypyktvsenonhfdmcsenwknngdcniaahksbzoeaafpbevdcplstefeeezoweprhnkplakipmehassfhkkeimteaholluvladgykerktnfweyeygtrdgtglbzgoglvwwessfdrpuyfrpmtnvsytwtlekshnyafsoeurldgllsaxtlskpyfwhntymwiosphekpprcedefgayhkrninndpdluislnrkzsbahfcflyjkleamonqzmhsrtylfurlfnnsadnbkdtecztkkcegsmhftvebzpkcheegyflwyndmygafxjnbzehgseyensfgwguetdrresayagytsgdhnuorocauouotnrsztswpkrhlfkovwjohddatansfphdcxiaeoceneechesrryihdemdpagepdosuthffwehfyhlvsnetevtchknrsdsgscafzoybwtpsotanshptansfwlrhdcxfekemoathhfhutsfcwjpwdgteyrtgdzenbaoztrslbtpvyjnbdrlsadklnolstfsgsztlfvlisiyaspsdykthsfrtbgdimwmcsaahphlcxhgcsotcnaxbbfrchiohflfaxtansgmgdmwbnhdasimkstyrldmcavolyeykblktsoybstpsotansgmhdcxiyvwcpcptddkeemdwfoylrrnspcttebgsbrnfmoetirfmwehhsrehdpmstdadaytoyaylrtpsotansgylftanshflfaohdcxonbbaxfdchqzlfcptlbbyachdypehyaxtecavlhymnmyceeekotpcamnamguclmotansgrhdcxcsrnchrnrpbsrnuecwaymoihplfnkgrdaxiefgpyidvysecnluhtwlwmpfwndnctlfoycsfplftansfwlrhdghykhlpmwerksnfseslnrpttdiltgotschpttlpacfctimjyykihhtfpteyllolsuesbnyetoxprseskhdykwlwnknstldahehdszefmdtbsdenbtbsndepddrroonbdmhztbapytatykimdvefzkinldpbyhymuwnkbbtvsflgshyzcaaetammwqdfnwlvlpkcmgdkovwesaeaojoaygafmjoynmecklartfghddatansfphdcxjemdmobewtihrohsgaghsglkgepdcmhdflhnamvegwssjzolpsjslesrwypkrydwoybwtpsotanshptansfwlrhdcxveoewfpmhgdywymkjylrndiseoytbdpantgdsrnbkihneoztasgreokecmchrsbtgsiyghclsabalkuywzamidctfsgdnnetihrywzmnhytbsbbnkisgswdlcmvyhflfaxtansgmgdosdrotksvdbtwsvsvevocycxgeuymtwmoybstpsotansgmhdcxrsfpfpfmldltkbsaamecmogabacsjtdedtsshlmdutaoaoylstndserdwdnedwmnoycscstpsoisfwgmhsiekojliaetoycsfncsfgoycfaorylftpsplrtpsokscfhsiaiajlkpjtjydpiajpihieihjtjyinhsjzdpioinjyiskpidoyadtpsojpiyjlhsiyftgwjtjzinjtihfpiaiajlkpjtjyoycfaorsldtpsotanshdhdcxnsvelewdmugsjksomhcsdngumosodnlffnlpcxfeylutcseeluatlyihdphyieadoytpsojsjkjkisguiniojtinjtiogrihkkjkgogmgstpsotpcxksenisjyjyjojkftdldlhsjoindmioinjyiskpiddmiajljndlkpjkihjpjkdlfwgmhsiekojliaetdljkjkishejkiniojtinjtiohejeihkkjkoytpsojoiyjlhsiyfthsiaiajlkpjtjyglhsjnihtpsoisfwgmhsiekojliaetoytpsojnjkjkisguiniojtinjtiogrihkktpsotansgylftanshftanehsksgdjkjkisdpihieeyececehescxfpfpfpfpfxeoglknhsfxehjzhtfygaehglghfeecfpfpfpfpgafdeceyjlgogmjehkkpjpjtihiygojtjlfgiddnfpgsjpjpfxeedlhdihdngdkpgwgmfxfgkninjlgmfyhfjkgmtansgrhdcxfhtkhnmyoeoyvdvdgolosrpfrosnrsaycmiycelnqdjyjzlplpeykgesmnvwoeimoytpsokscwiyjlhsiyfthsiaiajlkpjtjyguihjpkoiniaihfdjljnihjohsioihtpsotpcxksdkisjyjyjojkftdldlioinjyiskpiddmiajljndlfwgmhsiekojliaetdlfwgmhsiekojliaetoycscwtpsotpcxksdaisjyjyjojkftdldlhsjoindmioinjyiskpiddmiajljndlkpjkihjpjkdlfwgmhsiekojliaetoycseetpsotpcxjpisjyjyjojkftdldlioinjyiskpiddmiajljnoytpsojsjkjkisguiniojtinjtiogrihkkghihksjytpsoksgdjkjkisdpihieeyececehescxfpfpfpfpfxeoglknhsfxehjzhtfygaehglghfeecfpfpfpfpgafdeceyjlgogmjehkkpjpjtihiygojtjlfgiddnfpgsjpjpfxeedlhdihdngdkpgwgmfxfgkninjlgmfyhfjkgmoybetpsokoeydyeyendpdyeedpdyehgheheefteeetdpehdyftdydyoycfaorntpsotanshdhdcxnsvelewdmugsjksomhcsdngumosodnlffnlpcxfeylutcseeluatlyihdphyieadoyaxtpsotansghtaneidkkaddmdpdpdpdpdpfwfeflgaglcxgugufdcxgugaflglfpghgogmfedpdpdpdpdpbkgoehglgagodyjzfdfpfpfpfpfpgyfpfpfpfygtfpfpfpfpgsiaeogljlgshghfjegtimgoehgtghjefpfpfpfpioiyjthsisgmflgminenkpieecesguihiohfkoeefpkpkpjkgsimesbkieemeedneeecfegahdgwgrisfeglhgksfefpfpfpfpgahthgeceyhthgkskoiaflgofpfpfpfpfpfpfpfpfpfwjtgljlhkghgaehgliofpfpfpfggtfpfpfpfpgsiaeogljlgshghfjebkgtimgoehgtghjefpfpfpfwfphkihjeidkpjofxetihiyiejegejzgmeefdkkjpfyjkksgufljlghgtesdleejofdjegsjkghemdletgriygwhskoisecfgjtkkgmemfwkpgyeedlgwfwbkkkgufxghgrghkkhfenghiheefgeofdknhshfjtdldnjyehgwfyfefwiofsfsbkdpdpdpdpdpfeglfycxgugufdcxgugaflglfpghgogmfedpdpdpdpdpbkoycfaorylftpsplrtpsokscxjojpjlimihiajydpjkinjkjyihjpdpjkjohsiaihjkdpjkihiakpjpihhskpjyisoycfaorslrtpsotanshdhdcxnsvelewdmugsjksomhcsdngumosodnlffnlpcxfeylutcseeluatlyihdphyieadoytpsoiniajzhsfyinioihjkjytpsotansfphdcxhkrsoyhnoyuodrnsjewsylmybwmouonbtkglbbaxyakilfmnlaptpkjkiepszsdmoycscwtpsoksesisjyjyjojkftdldlioinjyiskpiddmiajljndlguinjkjyihjpgujohsiaihjkdlguihiakpjpihfpkpjyisdlfxgsfpjkdlgmfefpfygtfedmjnieoytpsojziyjlhsiyftgdjpjlimihiajytpsojzguinjkjyihjpgujohsiaihjkoyadtpsojziyjlhsiyftgdjpjlimihiajyoycfaorntpsotanshdhdcxnsvelewdmugsjksomhcsdngumosodnlffnlpcxfeylutcseeluatlyihdphyieadoyaxtpsotansghlfaohdfzmtiniolbreytcnyncnwmsoeyvtlkwzjzprlupebbbzghdnmnoyprenmdlflucaonsffelpfehkaaiyguzttartsfhdvtwfwdsboxfdlfbtwmwekbimdtemftatmhttbsoyaylrtpsotansgylftanshflfaohdcxplvdotinmnwensttrtlrtiisqzehrltlnlguhdludywzsebztnqdndwztpdazeqdtansgrhdcxfmlpjkhspautsfmwlndrpavobwpyotsazsdidwrnrpcylfintnwtgrnnhdhhpyjpoycscstpsojlhsjyjyihjkjyhsjyinjljtdpjeihkklfoycsfplftansfwlrhdghutjtlbhlwztbrdltsfvotnloutsabzjpnblnloehspbnseaojzceseeshtcxjsaydrltryjsamaaetgmcnctsfkbrhlfwpdtamhnyllbpfkgzeeyamfdgrinesemkpticlhljnvsytykwnfgvdesfyzsadhfesdmrdrthtfygshfvyoskbglgmcnhdhnrttsaogdbwlsmedndtynjzgdbehshlletpdrdtishddatansfphdcxiopakburhprngowmtshlrswzihbytpflgtrootzosfrpnnfprymuveasenotaeadoybwtpsotanshptansfwlrhdcxfpaohdbtndgyvsdnprcejtcwylaartjzdyfddtrosbpfbwsrwnhpmdmnadembdvlgslobdzmlphnvdbdskgyjnluzsgdtatinnjkcmtyylmucadwinjooyeosnylhflfaxtansgmgdstremsfwkisatnrdhlbbmhswdyadbelpoybstpsotansgmhdcxghchykwlghoxpftljectmyyldyamgycwamfwbnsbjelbsshkbzcnuttyrltlwtgmoycsfncsfdoyaxtpsotansghlfaohdfzhdetdtoxemlnrtltcncnpaglvoeynbehnewmbdjtzsperewlhynsisnekgmolrbyhszcwzlfpelafmdwenoswyspetdajsntytdlfepkpkidnswtchhhhhmsztbgtdaarywkylrl"

XID_ID=$(envelope xid id $XID)
PASSWORD="test-password-for-tutorial"

echo ""
echo "Step 1: Generate an Object List"
echo "==============================="

KEYLIST=$(envelope xid key all $XID)
KEYS=($KEYLIST)

if [ $KEYS ]
then
  echo "✅ Key list created"
else
    echo "❌ Failed to create key list"
    exit 1;
fi

echo ""
echo "Step 2: Choose a Key"
echo "===================="


CONTRACTKEY=$(for i in "${KEYS[@]}"; do   if [[ -n `envelope assertion find object string "contract-key" $i` ]];   then     echo $i;   fi; done)

if [ $CONTRACTKEY ]
then
  echo "✅ Contract key found"
else
    echo "❌ Failed to find contract key"
    exit 1;
fi

echo ""
echo "Step 3: Digest a Key"
echo "===================="

CONTRACTKEY_DIGEST=$(envelope digest $CONTRACTKEY)

if [ $CONTRACTKEY_DIGEST ]
then
    echo "✅ Contract key digested"
    echo $CONTRACTKEY_DIGEST
else
    echo "❌ Failed to digest contract key"
    exit 1;
fi

echo ""
echo "Step 4: Remove the Content"
echo "=========================="

XID_WO_CONTRACTKEY=$(envelope elide removing $CONTRACTKEY_DIGEST $XID)

if envelope format $XID_WO_CONTRACTKEY | grep -q "contract-key"
then
    echo "❌ Failed to remove contract key"
    exit 1;
else
    echo "✅ Contract key removed"
fi

echo ""
echo "Step 5: Create a New Public Edition"
echo "==================================="

PUBLIC_XID_WO_CONTRACTKEY=$(envelope xid export --private elide --generator elide "$XID_WO_CONTRACTKEY")

echo "$PUBLIC_XID_WO_CONTRACTKEY" > $OUTPUT_DIR/01-bradvoc8-xid-public-elided1.envelope

echo ""
echo "Step 6: Find the Edge"
echo "====================="

# No fancy find commands; this is the right edge for the included XID

DEV_EDGE="ur:envelope/lftpsplrtpsokseyjoihihjpdpihjtiejljpjkihjnihjtjydpiyjpjljndpieihkojpihkoinihktihjpdpideyeeihehhsieehihemetiyeyehieeeoycfaornlstpsotanshdhdcxhdsfzozcetjkztcmwnvaqzhkdyvlytswpmhttoprrtskioesiyhlkeotjecaknhdoytpsojkjkiaisihjnhsftihjnjojzjlkkihihgmjljzihtpsokscsfdihhsiecxguihiakpjpinjykkcxgdjpjliojphsjnjnihjpoytpsojljkiaisihjnhsftktjljpjejkfgjljptpsojzguinjkjyihjpgujohsiaihjkoycfaorslntpsotanshdhdcxnsvelewdmugsjksomhcsdngumosodnlffnlpcxfeylutcseeluatlyihdphyieadoytpsojsjpihjzhsjyinjljtjkisinjofwhsjkinjktpsoksiaguihiakpjpinjykkcxiajljzjzhsidjljphsjyinjljtcxjohsjpjyjtihjpcxktisjlcxkoihjpiniyinihiecxiajpihieihjtjyinhsjzjkcxjyisjpjlkpioiscxiajljnjninjydpjpihkoihhsjzcxhsjtiecxihjtiajpkkjojyihiecxjkishsjpinjtiooybetpsokoeydyeyendpdyeedpdyemghehehftehecdpehdyftdydyoytpsojpihjtiejljpjkihjnihjtjyfxjljtjyihksjytpsokshghfihjpiyinihiecxjojpihkoinjlkpjkcxjkihiakpjpinjykkcxihksjoihjpinihjtiaihdwcxktjljpjeihiecxjyjlioihjyisihjpcxjljtcxjkisjljpjycxjojpjlimihiajycxiyjljpcxguinjkjyihjpgujohsiaihjkoytpsojljoihihjpfejtiejljpjkihjnihjtjytpsoksguhgjpinjyihjkcxjkihiakpjpihdwcxktihjzjzdpjyihjkjyihiecxiajlieihcxktinjyiscxiajzihhsjpcxhsjyjyihjtjyinjljtcxjyjlcxjojpinkohsiakkdpjojpihjkihjpkoinjtiocxjohsjyjyihjpjtjkoytpsojoihjtiejljpjkihjnihjtjyguiajljoihtpsoksfeguihiakpjpinjykkcxhsjpiaisinjyihiajykpjpihdwcxiajpkkjojyjliojphsjoisiniacxinjnjojzihjnihjtjyhsjyinjljtdwcxjojpinkohsiakkcxjohsjyjyihjpjtjkoyadtpsojehsjyjyihjkjyhsjyinjljtoyaxtpsotansghlfaohdfznbytwmprtoiegsdekihpltdnrtstcnykzcvaenbkjlpejksbhnatlyontkvotpmosodmfsgajtpmielrlgzowpvevlstveadmknetdrkykbachkindwnrdtisalaltaxglkbpmcx"

echo ""
echo "Step 7: Extract Objects to Reach the Subject/Assertion Level"
echo "============================================================"

DEV_UNWRAPPED=$(envelope extract wrapped $DEV_EDGE)
DEV_TARGET=$(envelope assertion find predicate known 'target' $DEV_UNWRAPPED)
DEV_TARGET_XID=$(envelope extract object $DEV_TARGET)
DEV_EC=$(envelope assertion find predicate string "endorsementContext" $DEV_TARGET_XID)
DEV_EC_OBJECT=$(envelope extract object $DEV_EC)
DEV_DIGEST=$(envelope digest $DEV_EC_OBJECT)

if [ $DEV_DIGEST ]
then
    echo "✅ Correlatable context found"
    echo $DEV_DIGEST
else
    echo "❌ Failed to find correlatable information"
    exit 1;
fi

echo ""
echo "Step 8: Remove the Sub-Content"
echo "=============================="

XID_V3=$(envelope elide removing $DEV_DIGEST $XID_WO_CONTRACTKEY)

if envelope format $XID_WO_CONTRACTKEY | grep -q "security expertise"
then
    echo "❌ Failed to remove correlatable information"
    exit 1;
else
    echo "✅ Correlatable information removed"
fi

echo ""
echo "Step 9: Create a New Public Edition"
echo "==================================="

PXID_V3=$(envelope xid export --private elide --generator elide "$XID_V3")

echo "Double elided public edition:"
envelope format $PXID_V3

echo "$PXID_V3" > $OUTPUT_DIR/02-bradvoc8-xid-public-elided2.envelope

ELIDED_COUNT=$(envelope format $(cat $OUTPUT_DIR/02-bradvoc8-xid-public-elided2.envelope) | grep ELIDED | wc -l)

echo "✅ $ELIDED_COUNT items are elided"
echo ""
echo "Expected Count:"
echo "+ 1 elision of contract key"
echo "+ 1 elision of correlatable information"
echo "+ 2 automatic elisions of other keys' secrets"
echo "+ 1 automatic elision of provenance mark generator"
echo ""
echo "= 5 total"

if [ ! $ELIDED_COUNT -eq 5 ]
then   
    echo "❌ Whoops, count should have been 5"
    exit 1;
fi
   
echo ""
echo "==============================="
echo "All Tutorial §4.3 Tests Passed!"
echo "==============================="
echo ""
echo "Output files saved to: $OUTPUT_DIR/"
ls -la "$OUTPUT_DIR/"



