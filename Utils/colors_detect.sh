color_count=$(tput colors)

MAIN_COLOR='\033[38;5;69m'
TUXCOLOR='\033[38;5;3m'
HTTPCOLOR='\033[38;5;134m'
DHCPCOLOR='\033[38;5;204m'
LIGHTBLUE='\033[38;5;67m'
BLUE='\033[38;5;92m'
RED='\033[38;5;88m'
GREEN='\033[38;5;78m'
YELLOW='\033[38;5;220m'
WHITE='\033[38;5;158m'
NOCOLOR='\033[0m'

69, 3, 134, 204, 67, 92, 88, 78, 220, 158

# Ejemplo de uso
echo -e "${MAIN_COLOR}This is the main color${NOCOLOR}"
echo -e "${TUXCOLOR}This is the TUX color${NOCOLOR}"
echo -e "${HTTPCOLOR}This is the HTTP color${NOCOLOR}"
echo -e "${DHCPCOLOR}This is the DHCP color${NOCOLOR}"
echo -e "${LIGHTBLUE}This is the light blue color${NOCOLOR}"
echo -e "${BLUE}This is the blue color${NOCOLOR}"
echo -e "${RED}This is the red color${NOCOLOR}"
echo -e "${GREEN}This is the green color${NOCOLOR}"
echo -e "${YELLOW}This is the yellow color${NOCOLOR}"
echo -e "${WHITE}This is the white color${NOCOLOR}"