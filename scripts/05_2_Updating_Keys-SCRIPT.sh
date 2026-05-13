#!/bin/bash
# 05_2_Updating_Keys-SCRIPT.sh
#
# Tests all commands from §5.2, verifying:
# - Update of keys
# - Removal of keys
#
# Usage: bash 05_2_Updating_Keys-SCRIPT.sh

set -e

echo "=== LEARNING XIDS §5.2: Updating Keys ==="

# Configuration

# Create output directory

OUTPUT_DIR="output/script-05-2-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUTPUT_DIR"

XID="ur:xid/tpsplftpspletpsotanshdhdcxnsvelewdmugsjksomhcsdngumosodnlffnlpcxfeylutcseeluatlyihdphyieadoycsfzlftpsotngdgmgwhflfaxhdimbehkwyvooezmsnkpenoegstawdoxbzkbzejnjtsfwkmkbaidfzeyoygwqzmnihaxhdsgatlyynosbwqzmwjncxtdjerpdpcylyterkvwihgdsrlpqdtbdweyfrvynbuyguzsptjzqdidkbchkkfwgmlfjybzhgjpenykemdtjevlctuolnbghepdmyhgbtskcpgubygaspiefhgedatslfoycsfylftansfwlrhdromudepttaktrkvyvoksuortbgeofwlyzscklucmnsspktytcndlatpltdoejzwnjtsbsagamejpksglbwaefntlamskutuedypkytfgambtlosglgckrsmkgmeykpidaoprdteordfeemgsayrnieotteskntgwtbrouyltvljpjskklgwdpkbtpkjyuydiptwdenbbesbswtvatabymthnrsatpmgmktahaxtddeasinclkomygumhbeoscmbdrojtcfvsbsfpfrhkfrmuwklunydlrfsfcltbdtrobsuoutjojsidhflamycsntayfpvochdwfdiaidfztdwtqdtlbtmsztvemdbbhfvlfmmelkttahgslrludssbaddnltbzayfnrejpgdkohftpgsahladrhshseehnuekbdsrnethddatansfphdcxrtjnylhdvsfxlkcywfihsbfwfwwtwzoxrnrltdlpwlhlayjlftlkhhknjpahurzooybwtpsotanshptansfwlrhdcxfsjyjycfpapmdkkbgepmjztiasbdfhjypfayldqzluvlbkveflwpcmhnpmfwjycfgsonoshtloghihgshniyttcllpgdchbkjeetecmholzmzsfdmondnyetfrzmhflfaxtansgmgdcxgabbdrcfrpidtasgatlbdkuydsvsdpoybstpsotansgmhdcxiyvwcpcptddkeemdwfoylrrnspcttebgsbrnfmoetirfmwehhsrehdpmstdadaytoyaylttpsotansgylftanshflfaohdcxdncafzgdssbkftdpadrlgulgimbapdfgvtskwflsuyfnsgntcwdwidvyztdeaduttansgrhdcximsaoslsnlpsyafsdpfnsnfgoxnngdcfiezmlpeotifecnieprlgbbuocpvydlbkoycsfncsgeoycsfncsfllfoycsfplftansfwlrhdghjnvelolkpfaskngemdgtrndtbylbkkrhpdfxmslrztfspsbktoktfeltgydnuesbisynnesomktnehvddegwzmwfcnlbsglotywtoxzmlolflaktfxlufgbgkedptsjzttvybyutjpnsfgnndpwpislukgsrwdeopmrszevygswyjlfzlrcyihlsskprknkehngdrtimmobzwdkehdguwtbkamspollncsclhddatansfphdcxgteojzfhbeynssmdvtzesernidsekpfwtbjlgmjneyhnolkbwnrhbbdssomkonguoybwtpsotanshptansfwlrhdcxlsjtclhkmoeelbsapseyldryutstleldhgeoeyktvolucyfsfttivtvaurnnptylgseytncyzsdnnnztjkntgepmptgdtydkcfoytnjomyjsgacfjpoesklklogyhflfaxtansgmgdueiyfslsvdkkkkenbapstbpdndoluodeoybstpsotansgmhdcxhnpffrtokgrfleoeaxleimdigdoesgtkwmdpiapebgamckglndaefrrordwdswwdoycsfncsfdoycsfncsgsoycscstpsojzjojljpjyhsidjzihdpjeihkkoyaylrtpsotansgylftanshflfaohdcxlumegtzorkdntkrolkosmyrffndiwkrofhbblfzerodipahhkkcejtatinbsjtintansgrhdcxlnjzbnfwasfshtfgvehhktdschdwttrtctdepkbyhlhkbdsogwashkgobsqzgwjtlfoycsfplftansfwlrhdgheojzmofhrekobwpkbsrftdhebsplbggdlneymucatytbqdvesfvdsekplkmnlnlkgycwuyototlkdkwftinscxplgyiybzaxdesomndkbydmcehklrryahwlfplfadqzttktjlpefymdbtjltdbymskblewtqzihglgmsbgegsplynfzgwwldpospylyimdewdgdaasohewswdgesbceylwkeeswfrlaspnehddatansfphdcxayhkjpidzehpytiesnkofybgbbinntaezozstbctideyykdsbzylimwsvadplnlaoybwtpsotanshptansfwlrhdcxcfwyehbwlngootfyihldvownbgsokitykskpnljsykpmbtoesaoxwfeskbswwkkigsltayrsksutrttthdnsjzdkkogddazcvwrezepernkovwqdnelbvwjlmkhlhflfaxtansgmgdfmmofwzekkjnonayldsggrurwpeejzpmoybstpsotansgmhdcxyaflntkectinioyttklocelbmhaseswnoeetdmtprnfmytmyhfghimjzhebnctftoycscstpsojziajljtjyjphsiajydpjeihkkoycsfncsfdoyaylrtpsotansgylftanshflfaohdcxplvdotinmnwensttrtlrtiisqzehrltlnlguhdludywzsebztnqdndwztpdazeqdtansgrhdcxfmlpjkhspautsfmwlndrpavobwpyotsazsdidwrnrpcylfintnwtgrnnhdhhpyjpoycscstpsojlhsjyjyihjkjyhsjyinjljtdpjeihkklfoycsfplftansfwlrhdghkpcnssdiretkwkgteofhtykpsrroahvopeswnbvopymkfghgcfsrmkglbajtemkkrydktakpbyemmkcfhpnbskkgbbcxketdwecxdklfvayakgrtoxgrhkyacnlfkgsnfhrktsspcaclimdmkneczmuroncypdlsbsbgdnvsgslgksynhnoxbdpfrdmupsgrhngdaycwjyahvowewecwoemorpesatmtghfhhddatansfphdcxiopakburhprngowmtshlrswzihbytpflgtrootzosfrpnnfprymuveasenotaeadoybwtpsotanshptansfwlrhdcxditebbcsrnttghcnihwletpywdcageinykjofzmdpsltrdlatebncnrfssehzcdkgsfefznbptrojlwzsekbiotnongddigdtpenimgmfxsskkfmcysffxpesbkbhflfaxtansgmgdbzfsoesfgepthslbuelgadsensahfntpoybstpsotansgmhdcxghchykwlghoxpftljectmyyldyamgycwamfwbnsbjelbsshkbzcnuttyrltlwtgmoycsfncsfdoycfaorylftpsplrtpsokscfhsiaiajlkpjtjydpiajpihieihjtjyinhsjzdpioinjyiskpidoyadtpsojpiyjlhsiyftgwjtjzinjtihfpiaiajlkpjtjyoycfaorsldtpsotanshdhdcxnsvelewdmugsjksomhcsdngumosodnlffnlpcxfeylutcseeluatlyihdphyieadoytpsojsjkjkisguiniojtinjtiogrihkkjkgogmgstpsotpcxksenisjyjyjojkftdldlhsjoindmioinjyiskpiddmiajljndlkpjkihjpjkdlfwgmhsiekojliaetdljkjkishejkiniojtinjtiohejeihkkjkoytpsojoiyjlhsiyfthsiaiajlkpjtjyglhsjnihtpsoisfwgmhsiekojliaetoytpsojnjkjkisguiniojtinjtiogrihkktpsotansgylftanshftanehsksgdjkjkisdpihieeyececehescxfpfpfpfpfxeoglknhsfxehjzhtfygaehglghfeecfpfpfpfpgafdeceyjlgogmjehkkpjpjtihiygojtjlfgiddnfpgsjpjpfxeedlhdihdngdkpgwgmfxfgkninjlgmfyhfjkgmtansgrhdcxfhtkhnmyoeoyvdvdgolosrpfrosnrsaycmiycelnqdjyjzlplpeykgesmnvwoeimoytpsokscwiyjlhsiyfthsiaiajlkpjtjyguihjpkoiniaihfdjljnihjohsioihtpsotpcxksdkisjyjyjojkftdldlioinjyiskpiddmiajljndlfwgmhsiekojliaetdlfwgmhsiekojliaetoycscwtpsotpcxksdaisjyjyjojkftdldlhsjoindmioinjyiskpiddmiajljndlkpjkihjpjkdlfwgmhsiekojliaetoycseetpsotpcxjpisjyjyjojkftdldlioinjyiskpiddmiajljnoytpsojsjkjkisguiniojtinjtiogrihkkghihksjytpsoksgdjkjkisdpihieeyececehescxfpfpfpfpfxeoglknhsfxehjzhtfygaehglghfeecfpfpfpfpgafdeceyjlgogmjehkkpjpjtihiygojtjlfgiddnfpgsjpjpfxeedlhdihdngdkpgwgmfxfgkninjlgmfyhfjkgmoybetpsokoeydyeyendpdyeedpdyehgheheefteeetdpehdyftdydyoycfaorntpsotanshdhdcxnsvelewdmugsjksomhcsdngumosodnlffnlpcxfeylutcseeluatlyihdphyieadoyaxtpsotansghtaneidkkaddmdpdpdpdpdpfwfeflgaglcxgugufdcxgugaflglfpghgogmfedpdpdpdpdpbkgoehglgagodyjzfdfpfpfpfpfpgyfpfpfpfygtfpfpfpfpgsiaeogljlgshghfjegtimgoehgtghjefpfpfpfpioiyjthsisgmflgminenkpieecesguihiohfkoeefpkpkpjkgsimesbkieemeedneeecfegahdgwgrisfeglhgksfefpfpfpfpgahthgeceyhthgkskoiaflgofpfpfpfpfpfpfpfpfpfwjtgljlhkghgaehgliofpfpfpfggtfpfpfpfpgsiaeogljlgshghfjebkgtimgoehgtghjefpfpfpfwfphkihjeidkpjofxetihiyiejegejzgmeefdkkjpfyjkksgufljlghgtesdleejofdjegsjkghemdletgriygwhskoisecfgjtkkgmemfwkpgyeedlgwfwbkkkgufxghgrghkkhfenghiheefgeofdknhshfjtdldnjyehgwfyfefwiofsfsbkdpdpdpdpdpfeglfycxgugufdcxgugaflglfpghgogmfedpdpdpdpdpbkoyayldtpsotansgylftanshflfaohdcxtalofltezcdnfemduthpimmtwpvldszcfnftisgyvdatmnhlmtmnbkhlkiihbyldtansgrhdcxwslbqzcmchhhmsheclemgrkgptmhcwftnniszccfjobzosjzmtztltprmnspltinoycsfncsgelfoycsfplftansfwlrhdghlkdmktvltoosfgwdzerfjleohyfyottarshfiaynlovwvodpenaxdpmwimwntpvlpybepronbbtadifhltahcylyeeiesasebdaxmhmswyfpcnskenkiwzsgcklnlnnndypswmbtswtsctsgmwcmjlpdsptafndnhebdctfrgsgmgsemotsrcnlykpjektinaygdvwidcfplatdabwmdzeidykbwimdyckkphddatansfphdcxreadrtbybbgwlyjtdemhcsongsoehpwfuysphphdhkdapkztzokknbfyfwgtseluoybwtpsotanshptansfwlrhdcxrljkctmsdeoedmgtmdnehdghpdroetcyahuotbbtkoghkigshtotzmftfzsfvwfmgsynchwkkkcyjnpywfgyspgtcwgdwmldbbswttrnvocfvlkejslklglsldlghflfaxtansgmgdjneccmbdfhfnurotveiystbelddkrksfoybstpsotansgmhdcxcmtnkbtdwlcmoysnqdrptlckntdpfngugswtsbuofrbnfhnyashpfxsbvdyadriaoycscstpsoimjzhsjojyjljodpjeihkkoycsfncsfloycsfncsgroycsfncsfdoycsfncsgsoycsfncsgaoycfaorylftpsplrtpsokscxjojpjlimihiajydpjkinjkjyihjpdpjkjohsiaihjkdpjkihiakpjpihhskpjyisoycfaorslrtpsotanshdhdcxnsvelewdmugsjksomhcsdngumosodnlffnlpcxfeylutcseeluatlyihdphyieadoytpsoiniajzhsfyinioihjkjytpsotansfphdcxhkrsoyhnoyuodrnsjewsylmybwmouonbtkglbbaxyakilfmnlaptpkjkiepszsdmoycscwtpsoksesisjyjyjojkftdldlioinjyiskpiddmiajljndlguinjkjyihjpgujohsiaihjkdlguihiakpjpihfpkpjyisdlfxgsfpjkdlgmfefpfygtfedmjnieoytpsojziyjlhsiyftgdjpjlimihiajytpsojzguinjkjyihjpgujohsiaihjkoyadtpsojziyjlhsiyftgdjpjlimihiajyoycfaorntpsotanshdhdcxnsvelewdmugsjksomhcsdngumosodnlffnlpcxfeylutcseeluatlyihdphyieadoyaxtpsotansghlfaohdfzmtiniolbreytcnyncnwmsoeyvtlkwzjzprlupebbbzghdnmnoyprenmdlflucaonsffelpfehkaaiyguzttartsfhdvtwfwdsboxfdlfbtwmwekbimdtemftatmhttbsoyaylrtpsotansgylftanshflfaohdcxonbbaxfdchqzlfcptlbbyachdypehyaxtecavlhymnmyceeekotpcamnamguclmotansgrhdcxcsrnchrnrpbsrnuecwaymoihplfnkgrdaxiefgpyidvysecnluhtwlwmpfwndnctoycscstpsoisfwgmhsiekojliaetlfoycsfplftansfwlrhdghbeghhpfdvtoydiyngaaxttosyaoxgrlylufhylhdbtwestssutidgtenisuogrdyeolrlyctrfsbhlcmrlbsftfwpkahjljygylbideyhndwsonthtrlkibwltlafgwfbykgecbwpsnlhggecatpstwzfwflzsjnryecwmlbgskkltatoydsghbslntilpgwasgdmtlbykpmchjpcagsfgmkhydybshtwnjkhddatansfphdcxjemdmobewtihrohsgaghsglkgepdcmhdflhnamvegwssjzolpsjslesrwypkrydwoybwtpsotanshptansfwlrhdcxplsemotpyagoceecclgwjzkizteoisbgzoknwnkpnbuyhefednvainmsaxbavogogslupsiobaolhfetsbininmomkgdflmhkidmclnnoxiouedpploemocyluhghflfaxtansgmgdkkaeghwkuyykdrtllbvyosldmshnhetaoybstpsotansgmhdcxrsfpfpfmldltkbsaamecmogabacsjtdedtsshlmdutaoaoylstndserdwdnedwmnoycsfncsfgoycfaorylftpsplrtpsokseyjoihihjpdpihjtiejljpjkihjnihjtjydpiyjpjljndpieihkojpihkoinihktihjpdpeeehiaeshsenieehidehhseyihiyesenoycfaornlstpsotanshdhdcximprmsaylgfwcyjzzcamzmdrbdetjsrngamnbsfptbwtksihrhzonsahuthydwtboytpsojkjkiaisihjnhsftihjnjojzjlkkihihgmjljzihtpsokscsfdihhsiecxguihiakpjpinjykkcxgdjpjliojphsjnjnihjpoytpsojljkiaisihjnhsftktjljpjejkfgjljptpsojzguinjkjyihjpgujohsiaihjkoycfaorslntpsotanshdhdcxhecefsnnionspljpftktetwymnfmcyecveuotktpwenlhyhdpmpykpchcmzchywzoytpsojpihjtiejljpjkihjnihjtjyfxjljtjyihksjytpsoksglhfihjpiyinihiecxjojpihkoinjlkpjkcxihksjoihjpinihjtiaihdwcxktjljpjeihiecxjyjlioihjyisihjpcxjljtcxjkisjljpjycxjojpjlimihiajycxiyjljpcxguinjkjyihjpgujohsiaihjkoybetpsokoeydyeyendpdyeedpdyehghdyetfteyecdpehdyftdydyoytpsojsjpihjzhsjyinjljtjkisinjofwhsjkinjktpsoksiaguihiakpjpinjykkcxiajljzjzhsidjljphsjyinjljtcxjohsjpjyjtihjpcxktisjlcxkoihjpiniyinihiecxiajpihieihjtjyinhsjzjkcxjyisjpjlkpioiscxiajljnjninjydpjpihkoihhsjzcxhsjtiecxihjtiajpkkjojyihiecxjkishsjpinjtiooytpsojljoihihjpfejtiejljpjkihjnihjtjytpsoksguhgjpinjyihjkcxjkihiakpjpihdwcxktihjzjzdpjyihjkjyihiecxiajlieihcxktinjyiscxiajzihhsjpcxhsjyjyihjtjyinjljtcxjyjlcxjojpinkohsiakkdpjojpihjkihjpkoinjtiocxjohsjyjyihjpjtjkoytpsojoihjtiejljpjkihjnihjtjyguiajljoihtpsoksfeguihiakpjpinjykkcxhsjpiaisinjyihiajykpjpihdwcxiajpkkjojyjliojphsjoisiniacxinjnjojzihjnihjtjyhsjyinjljtdwcxjojpinkohsiakkcxjohsjyjyihjpjtjkoyadtpsojehsjyjyihjkjyhsjyinjljtoyaxtpsotansghlfaohdfzbzfslnetykknhplpwmhhcmcnwtfrwftogtrdadjtaxbsjkptmsmesbotldcstngyteisfhrntecemkoxtpueinjtmtfdrtvebwvtasbdcxeclafphthtfylfhgrhlabnoyaxtpsotansghlfaohdfzaxnliobdrssrgrltjnpkcfndpalabtkbglbdjsjzrtnerkbgsgisnnaattsamtzcvepklrdedmsptlcmoyfnlagdpyceneieidamkovtswjeztrkzcaoaolrylpsaabnaxrtgofn"

XID_ID=$(envelope xid id $XID)
PASSWORD="test-password-for-tutorial"

echo ""
echo "Step 1: Find the Key to Change"
echo "=============================="

LAPTOP_PRVKEYS=$(envelope xid key find name --private --password "$PASSWORD" "laptop-key" $XID)
LAPTOP_PUBKEYS=$(envelope generate pubkeys $LAPTOP_PRVKEYS)

if [ "$LAPTOP_PRVKEYS" ]
then   
    echo "✅ Found laptop operational key"
else
    echo "❌ Failed to discover laptop operational key"
    exit 1;
fi

echo ""
echo "Step 2: Update the Key"
echo "======================"

XID_WITH_UPDATED_KEY=$(envelope xid key update \
    --verify inception \
    --nickname "laptop-key" \
    --allow auth \
    --allow sign \
    --allow encrypt \
    --allow elide \
    --allow issue \
    --private encrypt \
    --encrypt-password "$PASSWORD" \
    "$LAPTOP_PUBKEYS" \
    "$XID")

if envelope format "$XID_WITH_UPDATED_KEY" | grep -q "Access"
then
  echo "✅ Access permissions gone"
else
    echo "❌ Failed to remove access permissions"
    exit 1;
fi

echo ""
echo "Step 3: Update & Store"
echo "======================"

XID_WITH_UPDATED_KEY=$(envelope xid provenance next \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$XID_WITH_UPDATED_KEY")

PUBLIC_XID_WITH_UPDATED_KEY=$(envelope xid export --private elide --generator elide "$XID_WITH_UPDATED_KEY")

echo "$XID_WITH_UPDATED_KEY" > $OUTPUT_DIR/01-bradvoc8-xid-private.envelope
echo "$PUBLIC_XID_WITH_UPDATED_KEY" > $OUTPUT_DIR/02-bradvoc8-xid-public.envelope

echo ""
echo "Step 4: Generate a New Key"
echo "=========================="

NEW_LAPTOP_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
NEW_LAPTOP_PUBKEYS=$(envelope generate pubkeys "$NEW_LAPTOP_PRVKEYS")

if [ "$NEW_LAPTOP_PRVKEYS" ]
then   
    echo "✅ Generated new laptop operational key"
else
    echo "❌ Failed to generate new laptop operational key"
    exit 1;
fi

echo ""
echo "Step 5: Add the New Key to Your XID"
echo "==================================="

XID_WITH_ROTATED_KEY=$(envelope xid key add \
    --verify inception \
    --nickname "laptop-key-v2" \
    --allow auth \
    --allow sign \
    --allow encrypt \
    --allow elide \
    --allow issue \
    --private encrypt \
    --encrypt-password "$PASSWORD" \
    "$NEW_LAPTOP_PRVKEYS" \
    "$XID_WITH_UPDATED_KEY")

if envelope format "$XID_WITH_ROTATED_KEY" | grep -q "laptop-key-v2"
then
  echo "✅ Added new laptop key to XID"
else
    echo "❌ Failed to add new laptop key to XID"
    exit 1;
fi

echo ""
echo "Step 6: Remove the Old Key from Your XID"
echo "========================================"

LAPTOP_PRVKEYS=$(envelope xid key find name --private --password "$PASSWORD" "laptop-key" $XID_WITH_ROTATED_KEY)
LAPTOP_PUBKEYS=$(envelope generate pubkeys $LAPTOP_PRVKEYS)
FULLY_ROTATED_XID=$(envelope xid key remove "$LAPTOP_PUBKEYS" "$XID_WITH_ROTATED_KEY")

if envelope format "$FULLY_ROTATED_XID" | grep -v "laptop-key-v2" | grep -q "laptop-key"
then
    echo "❌ Failed to remove old key"
    exit 1;
else
  echo "✅ Old key removed"
fi

echo ""
echo "Step 9: Update & Store (Again)"
echo "=============================="


FULLY_ROTATED_XID=$(envelope xid provenance next \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$FULLY_ROTATED_XID")

PUBLIC_FULLY_ROTATED_XID=$(envelope xid export --private elide --generator elide "$FULLY_ROTATED_XID")

echo "$NEW_LAPTOP_PRVKEYS" > $OUTPUT_DIR/03-laptop-keys.ur
echo "$FULLY_ROTATED_XID" > $OUTPUT_DIR/04-bradvoc8-xid-private.envelope
echo "$PUBLIC_FULLY_ROTATED_XID" > $OUTPUT_DIR/05-bradvoc8-xid-public.envelope

echo ""
echo "==============================="
echo "All Tutorial §5.2 Tests Passed!"
echo "==============================="
echo ""
echo "Output files saved to: $OUTPUT_DIR/"
ls -la "$OUTPUT_DIR/"
