ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
export FABRIC_VERSION=hlfv11
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest

# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d

# manually create the card store
docker exec composer mkdir /home/composer/.composer

# build the card store locally first
rm -fr /tmp/onelinecard
mkdir /tmp/onelinecard
mkdir /tmp/onelinecard/cards
mkdir /tmp/onelinecard/client-data
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/client-data/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials

# copy the various material into the local card store
cd fabric-dev-servers/fabric-scripts/hlfv11/composer
cp creds/* /tmp/onelinecard/client-data/PeerAdmin@hlfv1
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/certificate
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/114aab0e76bf0c78308f89efc4b8c9423e31568da0c340ca187a9b17aa9a4457_sk /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/privateKey
echo '{"version":1,"userName":"PeerAdmin","roles":["PeerAdmin", "ChannelAdmin"]}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/metadata.json
echo '{
    "type": "hlfv1",
    "name": "hlfv1",
    "orderers": [
       { "url" : "grpc://orderer.example.com:7050" }
    ],
    "ca": { "url": "http://ca.org1.example.com:7054",
            "name": "ca.org1.example.com"
    },
    "peers": [
        {
            "requestURL": "grpc://peer0.org1.example.com:7051",
            "eventURL": "grpc://peer0.org1.example.com:7053"
        }
    ],
    "channel": "composerchannel",
    "mspID": "Org1MSP",
    "timeout": 300
}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/connection.json

# transfer the local card store into the container
cd /tmp/onelinecard
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer
rm -fr /tmp/onelinecard

cd "${WORKDIR}"

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� Ǽ\Z �<KlIv���Ճ$Nf�1�@��36?��I�h�&ْh��HQ�eǫivɖ�������^�%�I	0� � �9�l� 2��r�%A�yU�l6)ʒmY��,�f���{�^�_}�US9�vL1������˃�mz�t�wΧ$�d�i��	��/-)>�����
��N��
��;(yN��[<Ǖm��qm�PsN�;��Z��h��Gׄk�`�PS���8�|����L�2\Y3��g�]�Zi�֕�P�X�ֱ��vb�R)
j���0��е��b2O������mUqK�t�⾋mCև��9��a�7-�obi�M[Sb*>���mH�;b�90��J`��d�?�g��3��ɔ�����'qWh}��:����?œ���TF -���K3�e��DS3M��p���
Fх�HQ鏪�����ӂ������]/J����Eэ(�zY=�{�)��}��R���H�y��"̀	�u�Y6ni}�>��AV�����M-S��Ų��=C���_��b����B2��A�($y~f�R����#b����I!r;��4�F�P����!�J�l�04�=J
.�並u����6���*U!d9(�����#b��<���(E�o��vX�(��n��Ӊ"tU�%@a���$Ud(�3�Ҁ�0N\SN�^'��?Y��(Bk�ψW�a��,�A��zPc Tf�#�}�O��v:�����!��Ӧ�f6;2f�����d��(�G,W�:R�sr��+9�����>�	�����C�[���x+
���}t)@W�4�v"��&<���p�[��覎e#�XqQ��)dZtr>CQ�=:�שr���
G}�cT�e%Ģ78���pF��G��ļ��[Q��_� 4I�5��5m,ܾ=�� 2��>ށ�p���~=vd�SM����Z����5��������?�Y���r����Ѭ�H�b���<'��?�N���/$Si�O��2����E�'��!�M���eg�bk��Z��M��H6f�:,�!�]��&��<�&�i@�c��e7k孽�b���X�\��%����]�_\[x~v��Ds��$�+b�^.��H���F�f��(k�s�1 �9�3�ނ��@Go�Q�k4�a9�7c��'��d%pma�	�%���n5�zc�Q�Hۍ����;�A���:7�a��2�ac i������Q2�����5R~�=BS	/�-�=~��	�-Od5�������MlG�gW��4+E<�Kdr�@':��5�$�=�h'�T ��k��w�oG ���-Y9�EE|�1�s�A���'���d��2	`&M�~f���S0�(q��<�W��-���d<�yV�bfT~��!R�-fh�@�I´ r�Ǔ4�����p��"˳��Oز�C�%����i���]#�j�Rgu��+�[�ʳuR�q]��'���q��&�R���;q��?��d��6Xh �Ɵ�)�.�l:8&ē�� z��:����"<䲩�ʁґ5cX㘺G�
#�)&�s����4]�ɶ���C�����OK�1�3mM�
��Ѡ@�%laCņ��NI0� _��CnHm�}��&>��G7l���[�&Z�}���ܳ�ã~��s�����?����E�����.S��M�<��_����\jf�Qf��v�)���r�M�mQ�jF��Wsg�X���_.K��S��1ef�ow9����M�$K�W� �ٿ��M�?����]L9���*��mu�!��Tu"��*�l�@��Z��E��8��'�ocx�oz,B3's^e��Ol��:����_0��}����G\����i�ߟ>��tZ��?����R�<���V�)�3���O��\���+���/�L����1�i��f;.¶mڷ�ek��_��veCu�9��a��v�6�~=��ؙmt�@[�(>�9�QLE?�!��{=�m�]��+b�}��}L��ɣ�F�o l�M�&�ʆO�P�T�q�R_�Z���@�Y�3�۔m�v�#86�^�$0���<��]�$����ͱ�<��977�u�n� �skҽ�ruec�cњ��L�"����D]�v�*%i�����97�t������ǙEw�����ۖ�Q��_!F��=8�/a�\^��K�ɳ1'֋k˟{4�u?M�>v'�"ץ��T�[)ߓ����^B�$L^j�/k�`oړ��Jb����!P�E�L!��9�v�,�"����xgx�
`�A��l1suP�ܜ�!}���y����^�T�mB�]��̿p��[!ah�M�gȿlB��o�A�[���gE9��$tDE��35�Ȇ�uοƎ�XA,�q�n�q�,����!���@1<,Q`��璙$�)�ˤ�^03	�*��FKk��ѱ�w��ٻ�f���?4���(��+nԥ�M	Ԡ��Yܨ��W7����1&������i�"�3I� D�$�}�n�99�8=�~q[���鮲Wy�T�k����
x�)n�M·��9�{�[���L��_p�S���,������<ڂ'�^,G��|�0�6=�!WnS�$�M)��e/>�"��.�Wx��4L��8O�P5�;��"�T/�/�яb/E����ڜ��M+⬼�rf���/N��?#�ϓ��������a�g�B������l*�����N������)��2����;.**�mő�N�T�T/�87O��f�A���+�ҵ������Ÿ�s.�>B���W��V�܂)�g���]��9�+P��t��� ��T9V�*E%;ȒmHA\��p��+{���M��=�q�#b]B���W��-�bB~}~l���O�����>��l�m�Ўd��6��>�4��Ak`M�ռ�D�!�#��(O�Pm�c�.�Uh~
�)t0ѲtM�Ԧ�&����F_�Roa�%��8��7:���� �4P	��{��f���#����a�����:�zoc�Ik`�C�Rv߀�C�'�L�N�nP@[06�@��M�9dǉ��P�`�������*20�,2(����O�֯zL^M�� C�\F.|d[�lQ�@�f�5&x6�W���<��'�.�0<���+Y���C�٢�,�W��G`��٦A��>U���s!l�q]d�N�)�c@˥  �Q��%�&�S��k8 0p�n���=' 2�;2���X�c@	3�|���-�0C�g �1������`�Ȗ�&,W͒�<����"U
R�M��q��M'�//=�m~l���pǥ>m��l�'��.w
d(�&w9&<�|�ilt��l"U����"l�#L�=�6�Ւ6jÃf�m���?�����[@ f�P�=z���:�k�2��f����ae(���c�bh�t��	�gb[咙�q�b��Q|�鱆J�&FL. x�}�G��̺�6E6.0�i1�@:��3J�^O�a�R�ȃ��
�5X`��=����+����a�-��ʚNɛgO �$on�Q�+=�[r��$�h��jc��!K��x>1d� �����M�e��]�#��T/M��oOя�&�K�P,�Ǿ�a�g���ĳ� B�,�� Ql�2�
�� 9�1Q�>����f�w����� Z�]
�Y�{��侏�G�'���&}�S���Bf����$Pd����h�v���c[�u�:bq�X|��|@�'���*�0w�4���{V�p��!qX���='s�C�!�@ߧH�F0V�&�o�۬�H�`G��Z�%�N�$�\���a]s�^S�dT�ipC�
� ������F��<=�4Lw<7ҚpӼ��ӗ\�K�%a�)BQs�Yo>L�0���JW#1�������xw S���o}�1�)��s��8v1�@΋	�"�:mE��&;<�3N�E�����߱��Sh���2�&��2�����B
���r{����^y��?��/~���N���N5�J:-,-�^��Kr��J+�KK�VsIH9�y�Φ��K��"��2KK|3�����L���~�.7�8"F~�{?d�.r��%����se��F�<��"��E���\��K��\G�ť˗Fx�Q�=�:q"ߋ���oE���߅!�'���}X܀�G~#�� 4T�a��q��C�O�߳���g��W�ߧ��"ϣq��:����ljv�1��^A�կ�?�˥?�ѿn��o����?��Z=�����/�������C����~��ܣ˗�{	|�Ϩ�x��Ӌ=��ɝt6��R����)5��a>�L�sM5�/�l&�l��Ȥ�%!�3�*/����$�)x W��ޭ�?����'����/~��_�{_e~���X�?Hr?NF~7�珸�Cӑ��(�㏦X�>���#�����ܷ*[��� ��������m���b���r�z��R.���r�r�X�/E�m��rAl�k��͍����MW����3��v�P��������f�V�G���㊵��N��*���lI�
�m�X��ׄG���P�f�݆t�R�ѶB�R�V���p���������#�a���ΝJ���kT�2:^]q�վ~�[=l6$�R0)�د4v���x���W�D���ۯ��2���2�X]-��*k�~�H�[hWw
�nC�w�z�'�����Uڽ߷v�ͮީ�w{+"m[�z|��n׍��f�j)B��R?��(���/������Nz�>�k�n{�[��z�m
S�~uw+3p�'�v��͇��dQ����XSJ��(q5���J�������A���{�I�K8�Ì�k<ٵ�u�ȭv��%Kwt�+wk��k7�\�he�z��?����v 3�ڪ�${%�f=�)��澽ڭ��dԻ �����V�b�ԣ���{R!q$ZD�k��Tn�ګ��?�9R{Mp%�!>��t��w3���������]�ձ��{�v0^	4�T�u��.������ve�]q��Ң�9������7�V��Ji�h���.�W��v&+���v�⪱(Z�lc����e7$�֪,�8[	���T-7�蟜jM�Ě��К�b��0v�7j��:0�4S:�k���)G�=�"0�T�;;��t$֙Z�Ńj���wA�=���_��Y��(�@�VX��
h�~�+,�W�`6��c��z���h4u���#fW�ۉ6���m�m|���c��7+���|��&׹��6���e�E�?��ંb����n��u���(c��y��9���]/������a_'F6
o�<c]����������QÉՑ�*�7	5�c��c��d�X;a��td�3b����ql���e�����C
���n)�
N3� r���X�2�İ�\۲"����t���v�^��!�e�luV�j�j{=���*�@B��T�eU��P4[dv��F�����g��?֒���<�\u���2^Y`F�p�U�bm�p5Fb�����X���U�>�k��b���d5+���J��D�����O�uh:��}Fڜ�qxX�H���m�\�l�i¤K�Y�H���3�w�7(���5r>U��`^�K�b���:��(զ;���@m��?>�1د�/�*��L�'H��(:����)�����hv�GHU�Ó7�]�4��s��*�@��$��O聒�J����%��y��W/ %�G��a�����Ow���z�DJ^c[����E�7��3�M6iN�Ut<�h�*]�	���W��oœ��t���Gh���:Ɵw	?T�xE��q؂趠n��N�j�bF�q��D��P[�o?u������
M��'|"n�l��+�������"��cNb�u����:F]Al�:��+�	`�����q�M��
���a+������`	�+�*|y�����^�"qo7��t|��~��7>튓C�����W�ڜ�����������ts^�f&�t����u��B���|Q��`��|�¿}��۫C���𿿆����������������������|������ۘ/E�M��ɚ;U�Z]r�91�2>t̯��~��z��;q�Xx!&�.�\�sT�r�G悞��ϙ��.-�ꊣ��U����	��+(�(�������
��*�0DzUc�H�J�I������VFD�M����QSX�{�b0����6tH��ڮ.�8��q&,{�;��~ -��)�P�`�,S���Wa��irhΘ�{B���`&!�jIᮾ���c-[�O�)����"�)RTd��偁�;�W��C��z�=S�~(}����L�uw�fW�c؞N;l�]
w�Ä]���;�A���ݘ,�P�=�4dg�����fV7����I���N�������h���l���֓K�Ԟjʺ^��F诇��E�_|���VX���wre�t�����c|�N��Ż�!`
�۩#a���:��I���ӱ�3���=���;t��GL����_el���&>-�C�r/c�� 
�Ҍ6�5i֛hO������l��j�T���^��2�q�m�ݨ��}9���&5�Y9�F�R_eH��TUE�	�.�0�P��2�0L\��,#��bi���t�s_k�_�n7��[)s��<���ʶ�R��DY�����4i�(ֺ�t�MW�w\�j���`!�:��!�xj-��PݶZơ�����Ū荹j 	�9�]	:=D�2����iļ,�?��&��G��j$�dwHu3��n@��f냡�)�$��t�<��@����z��"�W�z��1�@�:��`b��1��9(й�}<�������-�!9ћ�$js*�+A����D˛��K>*���&����FuD%'���3�ɾ��Py?\%�:F�{
ծ��%Vd��l[.�
g��˛RU#�#�:�
[�R5�0�)����e�q����!��L�Ko��f
��p��^<8L6h�,6ַ=xmM�Xa�m���P����������!<ԙN��ե�P��A�>ӥ_�:�n��Гn|�5حd~�E'��з7Z���*��0��'����h�;�a����M�K�d����8-9)����W�7?��#����t��׼�.|}�����#�+6���X�`p=��>�@O�MztV��9��M�
�-���??���4���e�����"��=Z�������������M�#��k�o[��V/�ɧ�
�������?YR���xb��y�	# �+�o�߻���k�s�c�`����Gi���=��1�
ޔޔ�T���z0{p�{�l��U[��	#�O�Ɏ0��_���~~�c������{�g�����k�d}� oA����pP�3��)�.��0�?���׵���B������O^�?��� 3�O�Xf}� ���g��(|�#���@���X��� [� <���g���2B.�߱���!9�f��$C��FZ��@�'�K�������6@�ƻ�md�c?,r���{��@���L�_�30�)����/��߳����������` ������c$��i d������u���r��	���@��/��`	@� ��e�\�?�]����_=� RG.������?�j[������j[Y���\�?��3C���J���%����/��f��� � ���g0�������E.�L��2�cwF��f ��e�<�?�\���SB>��!Qqa�Lˡq�"�G�.�x���ʄ�Reqp��<������ a��s�����:���y��A�:8��͖�9آ�kB����*��C��"[�؀��$����^�`��\ZUT�"�J��lm���P�a�I��e�5T�ɽv-��v9,�}k����R9w ��D�,��'���Zӯ��X�?ú��r��e��I��A�a~!�~�⦲��s�<�P�3;d��	��������y�P�#;d��ׯ��`��^,�����e���X�WPq]i5Q��ea(�jŘvܕ��?�58jUFk���_M��a�������ee:E�Ɣ@Jk��ag3�ʕ�rM�U�)-k^{ [l��"q<X�dsfб��Ku.�����S����`�7#d�덳�?՟r���e���@����?@�e5�4`vȅ�#��G�@���G��_�ƭ�k�~��,Bn��b'V��ON�Uz\�ݾE���}Y�c��d�w۠��6�V��L��a�����zX��ew{�-ReݚŮ��%�� ��� ��Bwڬ�V]*k��,�Z�尶]5	�6�yv�0��:�^�4e����J��mẙ��Vs��4��ǲZ���;�\iA�:�@��o]_�2��5߹��4�t�|&����`��!�&:e�ѨE4����N�|���[v��#���JyW�x���])��R����zK�q�a�Q�ZLK��5�9�����@������>��F����|����H�����_RA*�������g��(|���0��4�*��
��CZ��������t �����_�������+��/%����>/���/[���Q��+X������K������?���`�?X������G�`�������������g�����/���߳��* ����_��//y����
=�ߜ �>�F�?��c��o*��S��!`�*H��o������9 ��Ϛ�Q���_�Ȗ�Aq��������2C��2C������?~��/X����� -$����Z��?�P�� �@��l��=����K��0�AnHf ��e�\�?���B����3�0�GF.��=�(��1<��y>��8��G^��Zu1F0�Y����������?�E�X�B�8��ęvv�4��r@��_N9 �M��Л�
o�j:��%�rJ$5��~k�����tdS��%H�6�2���^�*XgXB�ʶ��qc��Έ��z�|{�$��O�$�<�Ҋ��up�fmR������h0tEr&C�%�	��қ���i[�$��*�m��H@0Kj���0Q�&ɢ�uM�������wF.�r�� �#d��@q�,�������b�_��CJ���␩#�������� ��A�GP�������8d� ��e�\�?���!W��C��\�0��@�GP��|�ȅ�Cp��2B��o���h�r������l���ǐ���0�?��q��<���.[� �m�#`��m�@=�˴K �[�y�����e
��Ï�������K�������o����}_zG�/V_`V��R��>�.r���X��"[�؀��է� ���z����PG���ZȨ���n�Ր�q��Etq�b��jcW�ͻh����be	��W��j�'HR<\��e���@&�� -����[Q��j�w�[1�\�wMx�E�[�wqSY�9C�?�������L�f�<����C.��������˾9���?���<�?���C�������Q�n�2[�_�9bՙ�֣��j�҂��H[��s;b�6��b���Z}=�'%.F�5���N:D�:�]E��`���k��Z�n�m�QH�Ԝ���nOB����(�OE>��E��"@�O���z�>ŏ�g�\���_����/��������� �	���/#<���D��ܭ���i�6M�������bY��^��� ����y5 �c"�y@q�kk"��Ҳ�"P���š��&k�v�ÊۡU� �hh\Q�LE;�Ի+c8�r�n{{ªלE(�U��/��;q�x�S�%:�������<��^�Z�cY�]e�dL0�]a���skN���=Ū���bWm@DPD�����o�����=�d:Lg=S5�mHґ���oJS~9/{�4�2y��73���޻a�Wt9l��^�S�b,��zhIx�u�lK��O����/��w�ь�k =ѵ���/b/H$��Be�vGK����H����9�!]�����:i^�Y���b��D΢��}w�	�#�3���;�m����.`�t�����Y���_�!�'����E��0ӫ����w��b	
���/����`����ﳞ�L�Ft��<O�Tʓ���7b��b�$IÐ	��x�����<��I0�W^������P��"~e�_[cW�H�6h����e�,�Ɖ���*{�"N�i�o��?l�E-�G���{+ux����������O3ݡɫ������s4���P�'�W��,N��� ��s�m�A!��MBJEDp}�f#!�i'�4�8�Ҁ�B6b"<	"H����~u��G�_�?$�J��b�T���A���e�c��&���懤s
�>��19����{]��c�2��r�[�2���R��?NB�WE z��f��������/���?
����������S��$/����x����?�����2�/M^���Rp�QP�G0���"���Cq��U���CP���?���G$�A�I���'���d����:8*���z�0����P���6�T�|e@�A�+���Uu��(������������W��̫��?"��Q��ˏC��'�J��v�#�j�#ÐP������,&����A���<�6�ˎ�%L1wK���2g.]�AQb�XJU��Ƚ(�y�F�'Y2��.�?F+f3qϔ�Z��i�d��+��x�<[�����?yjB��6���"�Ȕ��"*�V@�=���u`���߇�|��q̽lQ��ou`'���G�W3 ��)��Z����hV$��;�Z�bQ4��9K����6��B�}�l'�� .{k���ͲX&{���<[k,Blzi���ؖ�D�]�z!3��l�e+{����J�$�V���L�*��\�S���Ծ�F|.s���xy7��2ZѳA���+�L#�����v�����4{���ܝ��t��_V��뗴E=�ϻys����$P2s��~�\����ن��8jM.F��ɺ:^F.�Go��mQ]��q�N�_�}�8
6HM~T��[AX-�G����	u���Y��@5�����_-��a_�?�FB����E��<���i�}����	?�����G?�����j�㦤��17˕�r��+����/����_�*���_��$~�Zbp��tҚb���KmY���\'MG�{�Nz���O��ϯa�\
o����2��\���Ԕ�{��,����#>�TH>�w��"���z���4 ��i蘣�{��lbxsf϶��g;I[wވ[�n:	�h�p6cL���M��!�fܷY�V�jVsǑ��H��S��}����jYK4��*�EѼ��^����)�.�v~p�$]���]��j�Y�Hz�.�YsFv���)�����2<Mŕ��Lƀ�d%ۆ�$���"0�М���ҙd���r$帙�ِ1�|eu�q�ΕM��)p�!6�Z?�gg��cl�����v��Z�/� �������p H T�����B���_�������}N$ �Q�ϐ��a�~����������r;�-H��Z��/my}~}�OVr����>��m�
v+�'5 ��0m�� ��B��� �O��L�y�ͻ� ��B��4�����U�s�N�m��E�g��9n4?/�m=<�\�aL�9-��<���n@�v����xG���̃��?����S����6dQ�� \�:^�=�X�Z/痒��XgKj:ؾ�>���+jGZ��AilB�h&c�^!�����x�0;3Ծ��B��q�����-�DQ{�hƺ���E},��V�.�T^yv��.ɃZ���+��_p���J ����Z�?��ʨ��C b������:�������_m��������$�(�C��H��>�%�����k�u��|0��?j��q�C<��0�#��p>�$�萏���`X>����( x.B�!�i��-q���`��D���o8��ݮd䳦0[�,���>$Ɖ�z��q�n%��6k��m���;������..�@�����y#L2�-���f�L{�0�H#�Y&O�����G&d�͖{8w[��'�D2��)����R��?��������%�VI��������?*����\m`���ף���:~���G�ɜ��S�kc���4��y?����3�D��?�e|�N��åuiҽ�C�vS=�-�A:��u�z���S[�6��A
w�z�N6'U���f�ߣ�M3)q����zޟ*������OA��"�����?�������C��U�A��A�� ��8�1`�"��ɇ���>����������O��#J�������K������W����ڵ$_�Ub.ǁ�[f�S���[l���h���df�F�X�
��L׊8��ƑP����vA{FdgƜ����^ئTaY�Y7c7�{N`�������˾�ӷ�O�N���ܶT�����Nʔ�t�Ӊs��~�,�#QkfY?���Hj�<q��:�tYe:�cָG{�E�F�Y Me �w
ݭ�2�g��㐚����:uO~:<���]��8�t{S�Z��N��b�oĂH��F3�䰥�t�a���?�o�@�� ����+^k�����?�A��H���������H�a�kM���Z�I������]k*���W��"����W��
�_�����?����?X�RS������O�$��Uz��/u���A�?��H�����������'��⥦�����_��u��X�R'�����a�`����/�j���C�G���a�+<�� <mAq�?���!!��A�I���?�h���
*�o�?�_� ��P���P�_i�Ǽ:�����@�B�L�!N�81A&t�B,K	��,�PA��AIƼ��\Bl��b�Ϣ����
�?��+�?���������Cb�,$G#Q>����Z�}a-��L�m���n��M����ᅞ��ZW}����c������z�٪܍{8�L��w����K�WR�>h��B������]�Vm���V���'=�	x�� ��?5|�@=Aq�?���9�����O����/��?���T����?0�	������������d�_���	��)���U<h�Ôb�$"��(ay�O��b8*�h>	�8!h2���S���������2�_���l�����<h[�1r�mS3�=�g�C��O������v�n��-��JX��T�&Gf�R	��/}̲�}���ٜ���M��29E��;��.ٻ�R�G.$�q0[��Msق��[�����Ձ@�o�@�MAq�?��� ���:�?�?��Ӡ�(@��������X�������A��� �j������_����?H����f�� ���\��W��D�I��>=�����a�#`����0��Z��`�#�@B�b��n�� ����Z�?þ�����z��� 	�y���?�����G$�t��s�����Ήt��d/�,i��Ϻ����v������[[g�{��)�{����������$$Oz�L�Ԗ�f�����҇0m���T����P�8�Q�]]ҳ��/B�_o5�M��Dڅ<�k��,S)��=�W���X>�{�B6E�4��~.ɃR�ſ�x��ǿ���_��SѠg�v!1�x�8�,Xr���d=�.�	��,J������P��=�D���,4iI��;&�¨��ت�uA>������ʚ��n�"�{�`�:����������k����A��?"�f�S�S��h�͂�G���O0�	�?����������U�_��_;����������x����#�����������H~���hz��8�MI=�cn�+���+����Lqq��SS�̓r����yaMCu����C�)��\t���������bѪ}���˄�O�#��䎢
g����t���2��OZK�ט�BZS��zxa�M#�t�Қ���x��I�����5��5̛K�-���T����!��g��,��g��g)$���"���z���4 ��i蘣�{��lbxsf϶��g;I[wވ[�n:	�h�p6cL���M��!�fܷY�V�jVsǑ��H���÷�g��{�e-�|��)�)��sQ4������`aʆ�K��8I�lgw���nV�$҃^o��m֜�F���`����z�d�DSqe} Ӆ1`1Yɶ�3Ih>��'4�k���t&�=�	G9nfz6d6_Y�s��se(zi
�a��G����Y��[�-����Z�ă�O����:���\��]�=���v�W������#�V��!�E)C��1�3!�38#a�'tȇ\�QD�T�rI�NEl�P�	;�M������H�����K�7槙������bE^���E8mV�Р��6o��m��������#�?����m�ϭ_�Q��dݗ�n��.ۊmI�����HH�M�
�J��۷
 )R�%'�;B�sH(
U�*���W�r�{��ie�*�����ɹu����Z1����Tz�U��AM�V�NZ�֔�jo����k�o�T=����4=������S������}�������t�Y��m��'K�A�����>55���s��[����������Z�=���6>
�N�=o���^���Ī)�������0�t=��v��7k*�VB+���ο�7�����0ҟt4�R�9�&�����4���هΛ�>)��7����$?������R�8����s[�o��<���v����s��W�����?���������K��_��_��_��_��������?[�	ҳ����[X�)l���H���`�����A�9��(sG�
'7�TM��|^8��^>����%�;�`��X[���?p �g�� SU9��+����j/��Pz�7����R�͉cf���F�*yun�#�7���I�����t����W%�f�h8)*��7�\��U���d������^�1F��se��_b�}�.`���
�xvP�����ʃ�A��H�r��4-%�k^(W{���������"���n�S3�iڍ�ٱ}Z����O�o*FY?�T�,�t%R�$
,�4PJ����z��q��r��]�}�U)�������i�����1��/_>d��e󤤕/�^�u�fwZ��K�32O���/�w'��r#��8��;��/=�@�?���S:�׵�F���tX��s������T����C��˧�f�㤤뤍y6i3�j<�"�tZ�O�Ma��bu���טU$�1U�,��'����ТMKe�4�(��*�k���1���dD:Ќd�:�0Uf�d��#��\�O6� �c�AG�h���9��Q$�����b�3f
�c�%�G���nNHߴj�9���q��@�pT��	sdڎ��#y��3��ߍ��aa����A�A����q������`���~��8C�&6S8�8&a�����X��	����&�A��kIxb�v-�WqBN�qA��d����Pl��,�e@>갷B	�w� F� Բ��L�˱4f����)�mk�u&&��BW�����8B^��W����t�\��w
��%6���|��8��i�x��*��9.8A�j��0ˌ�&�<��2T=>�pº���<E�SWwފ���!�ݙ�߾Ž�����Mp��m�N ��46{������Tw��}�qd��>h-u$!��[b1{��v��i��X;�m�G�o����Ġ�S���բh�+������KCAopm��X���T��-���Y�R�Z+�>�r�$����v���-��I�h�L�IU�)�^�V*�싋F������2_��4��v�H���R��VO�t'�������7��%bi��L��!�	�+^��[�x�J�P�y������/�.�>���ɱ\��QT^yc�:��	���F�(��0�鐑�HP*��� E�+�~p3�3���'U��!a�|e6@آw\/�fDǱ�@�h�`�͇ǑWL]�l�@���8"��HR���^$9?c&2��Z�����8L��PB��É��s'K�����J���7�\�lLU�K�2�p�@����'����j*W̊�w��޽����eS��O���l*��|:�=��(	GX�H^�_F"���sZ�Y��6���t�,���	�2
-�ڕ#��x26�صƄɌk�24lg��A�ܮW.*����im?�%����%;���Z�% ���56-'��E�vE�#��ܠ�����B^η,&X<��,���%�_o�䮐����dj���9������dA�j*ͲJ��QJ���+$w�,C{*n��L:���l��h�����z���*��	��/95�M�� �����Qh��io�h�2�BL+�Rz�l9_I�5�+k܏���j�xXk�ڥ�����I�C�d_e=w��X�ӭ5J�j����'��������9�u���}�uE�'KJ�۹�yl���xO�~G�*���N�^ݗ�F�t��^D/|KB�321�+0�.T�*��9vsL�a¶�� ,��yjq���k���D=��\������#W�XXL!0 A9���~D,�:O!h}���r�_^v�c���}�ٮ!����8����J�:_�Z+���~8��5��f���w���H$�I\S+a��4<�v�Qy�V�X󎞇�zb����&�ܪ��1T=jv��f�~xѨu?6�ǧл}O�.�&m�ѐRA��\�U�-
"�K�lj�C��閺5�Z�ʥNm�@eX-�Q��<�U˲O��#����^1�������j�+�Ĕ!p��`U�{�V�r*<F�Ɯt0'�9�U��sU1�d?�~BD��v��;���~��ġ�l�վ ��'窹�IA5����\��[y V�9^@Ɯq�EU-_��O�)��&`��:8��1��.��ߊ}�t�ohN��j�wn6:����KfSٹ��l!���}�$tX�-A�bR��Ǘ��G����^�j����#��5�KS��#�Cap���:c�)�݉�l�Az'�ʐ�=P�\&3�7A����%�s�J��2�?R���Ϻ�L��2����O.�ݮ�<Jڮ�l���?������v�g���]�y��I=��ߧ����v�g�ܳ]�w���s�Tsb�q{�y���҅9�/�����c�K�4#ѣ����n�H�A��e;�Y�i�%cK3Bu���v<�g�b�T��<$�5|r-Aa����&�F�B�����N�kYx�f(mZ�x����+����/�ft��aG��Y�R�3��m����_%�
O�3t�%�]��L�9ksk�AK�ѻ�2"w��H�3��� D��F<,62��Y5�spZsX����'���{�J���%�'�|�F�y�HPR�Nb_^#�Ϧ���v���l�P'D�56�n˿���}L��?��������V�>=��?�"'YG��S�GB�00h��)P~��ѱ��/_]�K#�c��M��/�r|�'�OAn>��?�\f+�����T�}I?�a�y��|���I�Q�)re��?cC~��/x2��.��5좗����LCn���������^*���x���w=�x����0���o4��S��Q5���K��/ �Cg����Ԅ����*H�T�6iQ�f%k�c�N���'�yAb�$�_�6�_~Q(h��`/� ]�>~����NZ��AS�����~�e�6�&��kߓ��=������tA奢^�`���!l4맭f�;� ���I�@B����}Gl��d���և���:�r�Dz��)�LsN����g��Gp� �2dʕ�2+�Y���!ގ��Dn��?���T�2Y��I�� �0\]t���y �M������7��j'�{*��v��P;�,���B���0���
5�R���/<� .~�x{@��`�L�oB�$3h�O����rfㅋ����!5v^-�Kp�D��`�"Ɛ^�0 � ����@"U�(�.X����A�B��Nj�������.f���M#�׋"D�$�'��[�ys��e�8ޚ��F�t��I&�7�9��{�����|zE�;����򢎏j����m[�`~�f����	��%��x��p�k@���mR��^��R���rii��H��֣�،��4�۪_$���_�\���]2/�ƞ��^M��u<,{�QC�|ý䜱е�=�T�qN;��
\��{�wv7&��r�J�34-���
�K��怯$�?\!IY�r�t`��b"��/�|k'������c7l,5?
\@�VϬ�m%��̿�ʫ0������*�!����'�)t++"���q�����֦W��w�G�R�,��$+�{��R��$w��{��d{��^6�a�T.��Ҥ��&��-н^�@��fs��*�qWk[l�K�3��3����R��RjW�g��Yw?��	߸����h��f�@����4h�
���ƫ�Os�H �HS�9v�/��<+X�"�L�|��;3D�A-`�p�u���.%s}[`�م)\_e<��"�l�,֑�����1!K�"�3#(z4��O�Hǫ�9Iz��Y��.�o�I�GC��&/���l�V#8g��y9ucd��O��n�b�����-�Ro��n�7����J������H߻�+4FMzM5�G&�0%K|�x��;�M+ӆ��C�ѶN������?�d>�����H��??��0�������#��_Hm��%������� ��m�6����-��ILŎN(�C��i!9|�	�i_ЇY�S�&pR��H��V��f�-�l��a�wo:�R�{ѭ������]��$��!&�o���Fl���ʯ���K#�Kގ���SV�1��dy߭4����t$�����Z���Adߙ���@	(�D<�����j��?�a.�Xo����#�����D7��=S���_2�+<%)���Ln{��Qҏ�ҁGԜ�x��2<|�CW�j �%*㽉�S������C��xv]��u�MJ+̸�O���(��1w���=��ʿ?�}�mh��?UHo��GI�o2�(�Hw��L%��T��Ne�y����Lv��#=L�oH��''�>!r�Q��HU���ZB�n�C?6���Y�!C(�V!d�K��ɘZ09����"��;��c�?�_�GvQ�5,�/?��"�M��/���/Uq��ml��NG�6��V�,8�;������,�\Ӣߪ�<w�����v�b�1Ǝ�-!M��w�}(��b�ǻ�H�"����3�TՉ�E��e�`�)ʡ�[�WR@��9;2��>GfNgP*�Q�o~ߨA�#.?e�c��"2!u��C��Ub0����]%<�K��
z�\��<�+��,Z-w�Mh�
D��#�.�D�O]�08 ��0h�EI�`��1F�V>�A���n�y��'�N(~?"�V���BO�CE*B���׫>�� �7w5ˋm�U��a��d���j�o$�;>0�H�ygV�z�r\���Q\Ks�~�bom�W蚷�]Q�1Ջ�m���i�֎�u�z�É��R\(]C�N8lLz��9�y!C��'�i��O�Q�c�^lj~��c?PA��A�? a���#H𠍹��R������265���Ck2���g2��W�	_��2���Q8؍�&"��y;{�Zx�_s}��V�֛��π��kd�y�C��?M������j�Ł�	�5��I��<����z��FXJ�"��~9Q�l�OZ�q��H���z�� �m%��[�xpT�ڦnF��D����8!�-`�vIU-f��Kʫ�I=t��ޗ�Q�t�Q��ҁlē/?�X�����JI�r8�$m��w���,ñLݞ�>��%4�Kg�Y����(􆜊����#z���Ѳ �Y#߇��ʍ�Hh^�d��R�ٻ�Ǳ�<�;�[{fz�q�mviJ���tlǗx�J�['q'ΕF+�q'�ss�$�A�Bڅ�Zм�}�+�+,��@�yA<��V����*u���8L�k����������������>�+۽f���>��Z��m����V�z�2��6z\��to�q���=<��Un˫������]n�}y�-Nu��9�����^?Xy	lWp.i|�����W-."ѻ/�;i��w�"'��<��yln����� �z")o�|��23�u<��vx��˽�E������ ��d]mVm](����x�����ճO�&�N�4���`,�L��L���g������-��1��4+��6<��}��b������`�3X���WX��IM����)1�%�v#
�-��q�m!>��y����{���j���g|p��qY�G���?Ab�x���8��	�����zp�������?�������~�E갊a(m���`�Ҭ715JQD�N�J*�h�Qu*��
F����(�֣8��m����!�
xekB : /{�����8^�ނ� ��՟ÿ�}��ɋ<�up��:GG���:A�@�|�ﹷ��ͭ�kܸ/?�6t׭��M�v���4N�Y�뼻�y���=�K\���va���c���'�H0�wpt� ���џR�k�\��o����?j�L���������o|��@���O�]���ܺw��-����ca4��#"�HCS`�4H���`d�A(��	��r���kx���(�T�ڈ���TB���?��������?��O�N�S������6�C�	C��xeka�뷠�u����M��o����<����b!��}���?�_Z-�@wg�C�4�R�ei��N�-q�z��C���>j��S��Z�v6'I�f�^�hp����i��V��Ȩ˓[�t^��̫"�[疖�(?�W���O3s�թؖp�]SܲٲLڔ1!N�9�\&׮ʴY�ż���[x��U��~�K��]�%�N�^K�"����y+٪w3}�L�|ǉ9�
)~ʸ��N��V-#N=^WQ���u8�O3�j?�b���N5�J@���&9GK*'�4:�U��v:��0O%gL���������#��Q
�ۙ�P�����l:�MJ�|"ԩ��<�L
���h�|�p+�-%�c�9��]����c"]�&��A;���,/+����/RdK/�Wls@�x=���X�ʠjI�i�0b"	��,]�:�V��N����K�iAgg�v�,�m���h�)5�y�H�aH�c쨡r�y*=�Y!^1�"N(�r�h���'�:!g�vg�����)FK�B����G��l�{�Ie���g�Y��	�a&>�UH��wL�LRyu�KRy�V�I�y4�7I(�$���\�P�q��+k+e�>�35piB��8��2�L�X�'d�bTS�6n\��r�IX�N�D��b����TLi�Y�;\4S �������⺓j�2�i,���y/�#yc�й+�g�Ú2&���0��8���-h��d�C����&��(㳩�uZ䋬 ��(%���A]�jXT�Sx�
��Z��\+X�S�&l#�zO�n&9k�b=����#R� *%1�S`c�b9id�y��\��k��B�F�;��8���K'J���Nh#v�IEF�Ӟ#D&S��<k�Ί��s�N�r#>�O��D� �PLT�-z�'{�'z�N�m x�����z�z���O�՜爱��dr�2h:TC2� ke���g�$&��r�4�t���$m l����w�����wzJ����X˟�?d�G7C,Ma��"���+Ytdb��B�����p"-i�<Q�������1�А.�븓1EΉYղN3<b'��a��&�	gfT���T� ��bv��@nrJ��l��I���̲���~߀~�5	߆�;���/��Yo+�os|l�]����x�36����F��Nk�n��\v�"��k[��~�vxU/��$�WWzҁ����7�}y���w.9�����.�����`+�=��7�x�>��>��������
��R*K�]*k(�2_����<2�S�ex2_!M���W�g-�c]X�|==�U'�$�wpo�/�\Gk]�f.p�y�����$��W��ا�"2�5g=���P����eZftu%,�Xp��dX��"�]HH��%�1����i��("��'��E2�.,ԫ��хs5#�R	���5uԏ;���ѣh�<�tcI���R�:�"��%�D2~!��ꚑLw8F����4G��F�=2M�Ev�.48]2�Q���k0tX7�b3bK!���xo�2�t�Uc�^�L�ΜN��R�$h��i�6*ڬ�����*v�%��
�u*YW��a��F�N�Q����b=k���5�p���fj���J��v��h�Ù@�:�G�~�a=E��Q��j2,Ů$��i>�Ύ�q+??#���\�EFX���i96�Kk��fZk�6���*��GD�:˴�Y���2f�-�eܦ�)���z������t�MWW�s��X�^6�R�j"l���dd�n�#���]1s�Z���q�T�$�*h�t8�)R�����&��욓��(�5��������;�Z�&
�A&#�sD�F���T����̊4�����Ͱ�#�h�ܝ�xO�r���Ӊn6�!���\�NTu�2ŁP��xR<#���ТEe�R+ќ���d�ܑ��>�,��$`"M��*���'����N���h<ov؄!�$�T��c���t�0�2+�hr.}�t⿼tNddO�̎���t��U1ȱ�PL��R"��ĩs�$='N��4��Mp�%1�,�	���Z��c=�Ba����Z��=u~-P���{�@)$��T,�)�f!ǃ�2�]��q�����,��IM*:��CrQL�*T3a���H�0��^�����xb��5�$�u
XK�s
YLW�A$�Hk�(�Y��''ᄄ��:U�!�(���O1�F�0h+m��cI\�O��(��LW*�4GO� 3Q\Cz��ka2F1�0NaZ��J��1��9\��f��ZM-S�,gf��&�F/�륿}�����נW�U��I�Fo��9�c���'mt���W�h^�Cc�0A늇� �z���5��4�=�x��D��r���r�	�r �=~�y����:_�n�y�^�^��c�λ��E��b���&^�+z�.�Jm��7���2j�N�� ���T{����}����N���	{8^|��=���u���� �g�	¡C�Γ�!=��������O��j���}v�ￎ������v�k��&*�Uڸd����p���N��*$��fD��[G�<8y4�^TB/��{GJ�i��*��{T��㦷]����}��胏���x�DZ~3f��*7��6al���v$E��X������+�Ўxd���Ⱥ��uS?�#릎(�I�����]Q�����Y7uF=�n�zd��zd=�\xd}������{��6��w�\[�����~����`!`����ԟX���׻0��e���������~\�������d�/J'���K H���[zR�Ȥ�A��.
l�RHg�Ǹ�"ǒ⴬��#DK�}%׍��l�;����ʸ�S�^���H*���m��Zt�A�#Ù�T�o鲠p���o�=^�:�3����7��ٰ/i���Nz����D`���V�`�^�U��������������o��И�}������g���w�m�o��e� �	W�/RA�8�(�r(I:N:ͤzF�2:u�.�e�\@*Z&^6͉�4u�OI:n��$K���I�L�/;��y	�f/T��� +u�3)�����R�:�*[�^o,gQUT:�ǳ4��a��1b�'���������1��#
]������P�@�����;����P^��x���d�x�O�k��,�#��5�珽��02�����=��)��� O�.����sE@����^�?���4��]`7��L�sZ/�?�����?~�/��ҩ�}�����G�s����U��<���������#�|���������k�}��a_ۓ ٟs��/��O�g���Aؾ l_��i���=c�-�B������;����$X����b�{���9�?��ߝ`?����``G��F���c'"��_��~O@������p��]�O��6G� ���/������g�$��]`O��k�`����<����;A�m)ȶd[�N�%�g��^��������4��}E`�����^�`���=��`�O��?���������������`"��|���_G����P����/����A����� ��N���(�hp=J6p�KB�z�B5Lm*�f$�k�#�f�N)��`
&#L��=�W�s�}��q�����.�����_b�Ո����Lf�`�
���P�R8�`R��nO�Ȯ��Ȣ��fPt��Ch���pMW�Y)u@��I�����d
&^�RN��6�XL�fE*VЧ�(ۜ	��Lu`��4����E��Nc���?�%�m3p���A�������?���C���)�����?��,�?F�E4>��sh9\a`����C�ڰ�dtݬfYrl��c�ZX�)���62Y�ӭ��^ĺ]�"wq$<.q�J3�Mc2����A�Yl$&��gv����eKi���P�ّ2�����*�C�G��_���W�����ػ��T�n{����1����} ADE���{QP�_�i��s����>IQ;Y�)1�̬9��Z�+^�?D俠��0@��A����迂�@"�� ��?�����A��~꿖g�j��ԉJ��ih])�r��:�p���OԵ�66��_h�t�6~��F��mSiK��Mg�
4-���촟ֺ�������$Yc���0�����ф:�6�r�dc�j7h�a��M�h��i�kFc����V�Gu�����*���Ƀ��z��m�wZlT57��򑦹^�z�u�A����"�v��7�F]Wg�/j����z����櫪3Ce��ٙmwk�q͠j"�EBK�M��j��Լy�&Ǒ�ʪʧR��;��$wֵe�/���o���F�����k���l�������Ip��$�F�����X����<��������o�?
���8�:<�\�������<���0��?���B��x���a���<����[����,s��򿘀��a�a ����/��X �_��B����A�}��s�����H����3�Ü�@�����p���X �`���� A�1��*
���?=�?��q����y�������������?`���^��ÚP<����������+ ��@���,�|s ����p�W
��)������?3���@�CYH!������������� ����(�������	��tCmHq �����/@�_Q ���<�>D���������q�-�������?����Q�fjo�6�~݉{���R�����s3~nO��Ug����2����>�Q"�mU9�v|{�@�![:
ʢ���ǝ�յ-4r��ܗ�n��)+;ldF?���3������c��ֶ��E7�����E ������SH'W��š��T1�e,��g��44�u��l�~ʖ��T9����n�҄TY9f׫ײ��	�Y�yP��)��X�!�:�?];�n���;���
���P�����������������?���w�3��� �?B�G�������+D�As�B��{�?"��a ���9$~�����0@�G����/���B��o��l������[����s��#����?��R�8)�D EFᄣ}6h_�}F`#��e%� ��DG���$��,�Q����޿_$�?'����ǃ��ݱ�[��c���͚��٦vښ]�W.�����ǹQ�L:G׽׍{�X�����7G�D:S}�>�1�~��ǝV=ZT�Q����z\�;�N�![n�R�쐱�c'9�w�x�\R�B��is9�ä.��[���v=�M�<���|hD�N7���M��l���ݼ��/8a a����š��?[¡o� a��W����Q
�������})�%H����#�_2�/�y�o�u�<�)����`�9��̪�ʉ��2w����n�$l�ޖM�D����_�+9�l*�N]�/i�/�5�W����y�5wI=�Z��k����M��V�2���5ς��U�����$�(|��_��+^�?D俠��0@��A�����"�@�� p��
�[�op�q��kN�D���̖�� ���&���뿧���~� �\�����=Zb�E�-UfRR�Gy�tO�=�Ŵ����'�Z��`>���$���7]q�zI񢳀�� I�~���%g�Җ�8�]�QW��!5��O:O{x�V#i������'����U�ܮ��H�+�
{��˱�Hd�\g�_��●t+�pY:TE����S��o�h��_��z�7�b<�/���w!=�j?�6���W�4��4�X�M�^��*R�<���Xg=����''�E�܊[�f��+B�[���5���F��O�Fm�o�wn���`�l�P����	��8@��g������_,���=���������/N%��8 �`�����_����'��>EYfh.�Y�z����)#��d$ӗ�]0��E,#\ad��®O��������]a@���G���5q��LhWT;�{�Q1F�Q:�tG�y+0T�(V���)���e�U�P�+[ ��� a�g��P�����=ݡȋX������/Z��q��g���_�f��q �K����!_���?9R".`��a^���Y��(�xN�'�b t�+
這��,�����X��ǂ���Gjm�����_�4e�'�Q�oo�|֏���h�N�Z���n��/����ĕ�ie��
"�������g���^������/�����꿠�����K�O����w���a$��a�����.f�V��;��c�������7��?1���������:������_��H���o����?�����~w�!�P ����7�_`�&���	0E_�o�������?@�㿋��������p����	���z�u��}6p��?�d^����/x+���+5\=�\��앲e]��B:�rM�̙kg�Ms���2�����FϾ��kƩ�����h0>+!������Y���xluo�5s4t����Z���S������
�CT��m�CT�k�����_ρQv����wr`��f0�9�E^͟r`G�����M��")���e���W�"����.ˈ#M���d�����4��r��c!�{�Q�6�s�L-OO��2��j��:��§��j�9t�m~͎'^�(L��U:���W����k*�\٪��_����LJ�^?Q��b��'{�zmyV��PoX��([n�Ԉklf�{�mWԸ.��/\k�95G�E4M���ԡ޹�Ȏjŕ�n^^z�L!#�3��K�\�5=qW���N}tn4�q�2���Dtt����kY=$��k�Ůa%aϠ�Ȗ�i���aD�{����,^�@A ���������;�C�, ���?	6>$����� ����-�o^��b���o��N�4)k�i3�fc�to꿂�G��=u�\�e��i|�{�T���5]E�ϱ{�L������4p�^�;s��{��Y������1��1j0���^��neP�{/�2"[��)�|p1����
mL�S��J[�f���Qssq�����y���l�̅LԧԠӫk�us1�Kˎ�PCmTѤ;�	�4��I��NW�R{��c�8�qޘ�zZ�Vy�z(�z��p���XW�=^չ������Y���+��V�1�K��)Ԯ�\��6Yu��B�֎�TE{�օ���V7?^�CQ���U,�§W�*F��{����YJy��$���z��}�P��c+�
q�r�ɦ�1dX��H�.5�۵6�g�
�H���uԯ_��+ B�1w��A���`�����������B�o, ����� >������?�Â��W����~���a��(��̈�3�����t{��r���X����
u�� ���6�� �z ̯g 䇁��cO��sO�w� �� �p���~MwL����,���f�x���iy�ZePc¦�=���-E���W=ď;�r���;��$�E�+����� ��H��*��ӈR<�9��-6]�R��	��%�����t��h����joT1dV�y+�<=��G�X��.�ˌ��X�)�}��lh��F&zc���Ԅ�t-���:����*�D�?���� ���_�_��o�G���/d�? p������������h��@��c��?�8@��[��4��Bp� ����$�?������?���s�>J�с$s��J�/
�r!��<At��t�YB��H)��	�Ľ$���������#�Ѵ�7�Zc3++��/R�ڧ��0t��ryXV�08w��?�������Nb{�sU�ҹϯ*�M�c��/���NBu
^�ƚ��2���f�k�!���{�SS���pj�tcW`�ۯ��������l	�������_q ����Ga ���_X���� �������퀳�c)k��ji�H��Ԍ�Jmޞ�;��;�L�����X�'��Yw�]:�2�*���njMf˽�F�)M9�Yqxd�Uk[�F{��u��t�Mu���z�űI9�i�a���zޞ���WA�����oA `��_��+^�?$俠��8@��A�����b�@"������?���[�������������U�����t~���=q�WM?Z�=j���ӵ�66��_�ׁԯ��璦�[$��\�e+���(�c����D����UK'A��80f3�t'���7��\=�3eq��f�XL�3�i�����&�n�� ~������r���^U�m��^�i�Q�.�:Wm��b���Z9�ۡc�����9��C���-Y��a��R���m�@�چ[�j�����nOO,��>7�'V�ʇ>�:6�㨻�+%��7ԙfu��Y+M���I�Xf�����8��R��r�r�Ni���׭ A�1���������ÈW�����u�G��p���"�_���p��x����
������e8����]I.���W�b����0����ś�'��c�#^H����H��e �_��?�x!
D��;���X ���C�����A�}���/�����$�?��”�a�Q ��ߛ��C�,��/0�����_����w��y�8��������w���!��@�����P��X���.�o��z�������C�����?����b��(���>�˴4A���F
BHy%�hY�C���{Wޝ8���ק�u�NW�۠�����8�}����H�@HX��~�͔��]�60S�~�B�T��ˈHe��d���L�����}������������xz��?�?�/ͻ��l<��D�P�^���Z��kw=�>]��v3��h�r��\��v���Tm�T��]1�8Z�5c��ܘ�M���q�>�zi�ﲦ0�F�_�v�t��w�,;�w�:������J�0�S��2��A��ᆏx	�D���3�������)�?M���{��{:����N������Ӥx�_��/����;n��}�����A�P�Բ2�G�̐#.�Q;X�Ԕ�R�&�Y.C�0�!3#FeR�pl*��Q �����)����������{������ay�e�ݤ_�#�{��]�XzTIO�u�1pac�[H��?�`>YMޥG-Iqg�H*)��@��C��Z5��LטP��ܢ<F�,թXv�׃���Z��,�=���ōlX�x�4sq���t
��?}<��,��S�C�����i*���N�irO�����t(���g��xZ86�������Y�/��ˁ��������G�j��O�9� ��_�8"������?�,������?~?�t(����h&^�?��?��?��?��?���s�c�����	����߆8����m���G�������������� ��)�������b�� ���:��W�v�tg<~����i4�]��o��������}��m����[Uŗ�{�5���(v�ܹ4P�eI1a�ͪ~�xͻ֬�&h9��t�
s�.��`ƕ��RJz@���\ƺ+��#�>eN���J�jU��{b׿�|�B�^��	!Vy>(G��D�A��w�xb�ǿՍo#��fi̗Y�.��D��f:���4M[0gCk0�V�#���,������Y2��_e�� �2h��a�w^
������j��ڽjoV4���?`:	�����������>~����(��m��$�?�'��� tZ��uh:���O4���������������������#�[?vo�z�����w���G�����{���N������G������Uq�����_�z��
+��3lij6�z`�z/U�*?�|�qU���K�oEN�����R0g�;�徴�O�ntO��z�!u�G��y?�3�B���2���]�%x3+7�;l�&
M.�9^��T;]��ތAq�֪5�MJt�S"���i�0�ܤ����X�φ2�M,c+����~����~������N_��/�Ly)4��t��T{ve��n�A�?Iy�ܘ�:�BѪL�=�luG�̗��6�T�r�y����\ɭj�Vz�J���'��P��l��>|.Z��c[�s|5t�[U�e$~��U�}�RМV�2_f�P�9�$d	�U����|ֆjI��Ŗ�}�*���Wy��Yh�D�����KM�u��4!J���@6#�gS�lrlϹ\)�V���QK�%��*��Y�z��y[��R)�f9�M���ņL+��r��m���?�����=���<���7�+׳{�G�������S��,�����A��_)��R���iJKeR
�I��lV�$d��©jFU�4#�9�f�dԴ�b��BB2�F���)�����c��0�������ay�4���'kiµ��¹�.�3>{�,��$_��ӕ��>����hmk���E���0+��+q�S�@ƕ�3�Y6�ղ�3���r��KF.׭4��
ښ2O�)���VkY��b|��[�������ё�ό}�J�0������$�?>��ht���@n�;��S����;����ךR�/K���sz����Q��g��iőTk2N�T������
��K=Qo$N����uv^�.��}rL������rȒS�l�.S[عn�}�2�8��;��,H���7%�,�Ɏ2L���[�4�:���N`�W���;������_����Q��+����������;n�'��A'a�q�3��I���!�5�ox��?=���Cg����П�p�e��i9x���69������y�?o�\Y[�?���� b۞ݻ ��j�g�~��J�M ������Ͷ�e>y^�l�|o[�����8�'��uP��I��k�{�>�k�^�+��vΥjײ�s�e�"��L�5ϚM�����Ǿ���&�s����x@������GХ���O���a�@���bR��VX􄜒��=�
�3B/e2��:Ӯ�5�[v���@�l��¹��sxS
�5-�M���N��JM�$��d����dF��U�|0(��r��E����]����z�7�	�&aۮwV"��MofW�l߻��3��jT���v��w#���s��X�3��2^��4�һ�O�X�����	��|���%����y�	Z8�-ʅ� >�@�����*�\xQҠ�#:�����^�	�C/ޏ����A'45�3prpdX68�=��f�%놥���`�t߹J[��$ x_�ߺ��}j�^n� @ΞɆu	��0������s���؆4"�
4� �l`�1���а~Pmª\�?q�m׳��Y����o�bla�oj�Q�S*�!�G�}�v|��~���j?C�
������x6����%C��s�P�ȶ����������5�h���P� TQ�#LwA` �d\���@��=�{���5��� �H���8�
�Q�<ǀ.�-�9�1m��v\%��l��
S[�ۧ'����j_Agj?����\)n�zb����̶"��R!C6��u�T���n����������p��b�OX��}��=c���N�}����#�i��o	tI�og�e��Ƕ⡼�|Է��QG�=+�������'�B�2t�X��\%>L������l��hP�8C)��Eg[M�q���p��vn�q3��CQ��"��7s5�[��go��y!����e���/ȴ�7�hCU�
���v�J����]�D��P�����Ms�f
�����Zb���5�����?���)�h��wAm�n`�h�[=�%����4��3!�>����&6�=<U���K_]�[7�A�}<��TM��^��ʗ�M�`�F����X��`�;Ʋ=0�=w��]�E+6�;���k~kHwCN�t��PǼ�օ��<v:+��iGF}��r�_Xy�6M��l?Hr:;�a���i7��K�zHxT�n����7������7�c-&�N]<�}�.����#�xn���{.�E���i���b�������}2@�8�?�������0���|[����d)���Ϧ���?E�Z �B���UbO��@���x ���x+���S�����(����.�=2��*�%g�oP1�(���}O0mu
�u�G�
��}��X�,hnX�!\�;�m�j��$l~�r`s{�r�`���_CÂ{4�N��|�/Ņ����-a��k�t��X�Ax���t	~�#,�
�9d�A���b�dM���:&�t$k�Q���|K,"k�L�afh-Ƕ�C�gـ[�W��$���^vk���`[j���U��=�%>}�)�ϗ*o(|����t�/�,~���5yĤ�
-�J���PN1�I��鑪��q#J�i�A�giM)�lZf���|�N���0No��82�^�?�A������"��i}"��r75��7��{��G<�p�c,����S��($�!9M�(�*)geYN��,��L:Y���2�z2��,)9-C�1�B�q����y .����Xئ?�[ݕ��nUN^��5�!�����N�'�(�:�\�>�'�+�~�mj[o���T�Z|�R/T��T�Ҡ��/g+�;R���ZR�}E&��^̍�m��U�S�箰���u�zm,��,��%�j�Q�]�-t�j�\���
�p�u��!��v��W���$������썓��&u���J(K��jWi����EG*Nb='�	v$���t�];�v5�~X��R�m�_gp�{�w��R��*}��B��}�WD?�6y�-	y�TCV�$��zx_,�X�=�t"'	��n�^�V���R�s�[��2�L�8Kr!;IǷֶU�ݖ��I\�-���4x7�F�^�M$Գ���b=Z��;b��/nkR�_o���uW5��v�w�Q��֛�L(5���$W�AYA�г�ߑ��9��|[�Bn�:�	��/ֻb1'�۴��t��ה�T6þ��>��<̣8�b�{��0���l���v	]08�yI���rW���޿�?��}2�?Yn���V�[!wΡ�����}�ΗfJ|o-�6ұ�^��>�lX<E�'#���Q��QN���*��CݙDs�l�J� ?��Z���V�σ��ف�o&������O����4E�KQ8�� �7��A��#�VR��1~mCZ�%1��� t�����l�ts^;���LzPū����|X֯�金��?1�#+a�[�/o"�E�mg� ��t��P5��Aw�'�>�� �xۮw[�������g�/�@C�0���G��`��s������������A�C������>�*�)�r��x� S�G�ySf\E\_��E���0�<H|r�W4r��%�	Ӝ�v�F+Z>�D��
�氛فZ�X�&��Ux8��xj�*�~�`}������M�����+f4�}gӥ���� �&��_2��/Mo�׳�?���^���b����B����)����t��� \ʞ��9*�0W ����fNx�}Op`�9aX|s�?\\��"����?2�B����i���\��� ����U��*��ձ�X�c�N#X+�p \���Q�z��mA&(�0F`�j����$���an��1�n_\l�/��)��'�o ._>��M���<@}���(���ޕ������-R�
�0UzHm�����/U�1��k R����]_`�^������;w �P _���A�!�pr9O��&U�M�Ƌ�K{oJ�䆚e��uD-6�~�m�@NN��#�43�-�aA=.�s7�H���ӽ/�HdD4�oC���ٿ	˄���	�DR�E�3c��D���T�����
��z,���9�zwO�t9��%M������Z����� ���M}q�1���4��7>�bY�\%	8v��A)(�����zeh>�6���v �J#͜��l��Z*�Qd��_j@B�R�%�첆�toٔ��Ԟ	���omLׯ��v*��"~�\&�h�WK��X���̄0_�C��'�&��r45��T��g�v}`���`d=ϱ���G�;���{愎��zC�
�
|���������ﺝU���w/\/��a?Z%HC�
'LP�Ak�9}�v:.�4��;Uo��l:��ZA+�>��Z�4��b#�n]ӛ@ג��L��y�ҵ<Zg��6��Y4UM$w�Bebb�j5����y�-�)�(��@�����P������ٿ����T�Ƭ�����Y]�9�{�ZN��+���}�G�_���:}T9|;���[�/]���}�~З��%��O.���5�K����� ������������n��jV�M��\�äV��n���s���?�+<F4���.�M�!�'щ�Ƌ�c�6��$���g��A�t��N����$��`0��`0��`0�_�o4��d 0 