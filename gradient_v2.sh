#!/bin/bash

# 색깔 변수 정의
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# 환경 변수 설정
export WORK="/root/Gradient-Auto-Bot"

# 사용자 선택 메뉴
echo -e "${GREEN}스크립트작성자: https://t.me/kjkresearch${NC}"
echo -e "${YELLOW}gradient 노드를 설치합니다.${NC}"

# 필수 패키지 설치
echo -e "${BOLD}${CYAN}필수 패키지 설치 중...${NC}"
sudo apt-get update
sudo apt-get -y upgrade
sudo apt update
sudo apt install -y git ufw wget unzip

# Chrome 및 ChromeDriver 설치
echo -e "${BOLD}${CYAN}Chrome 및 ChromeDriver 설치 중...${NC}"
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
sudo apt-get update
sudo apt-get install -y google-chrome-stable

# 최신 ChromeDriver 자동 다운로드
CHROME_VERSION=$(google-chrome --version | cut -d ' ' -f 3 | cut -d '.' -f 1)
CHROMEDRIVER_VERSION=$(curl -s "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$CHROME_VERSION")
wget -q "https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip"
unzip -q chromedriver_linux64.zip
sudo mv chromedriver /usr/local/bin/
sudo chmod +x /usr/local/bin/chromedriver
rm chromedriver_linux64.zip

echo -e "${YELLOW}작업 공간 준비 중...${NC}"
if [ -d "$WORK" ]; then
    echo -e "${YELLOW}기존 작업 공간 삭제 중...${NC}"
    rm -rf "$WORK"
fi

git clone https://github.com/airdropinsiders/Gradient-Auto-Bot
cd "$WORK"

# Python 3.8 이상 설치 확인 및 설치
echo -e "${YELLOW}Python 3.8 이상 설치 확인 중...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${YELLOW}Python3 설치 중...${NC}"
    sudo apt update
    sudo apt install -y python3 python3-pip
fi

# pip 설치 확인 및 설치
if ! command -v pip3 &> /dev/null; then
    echo -e "${YELLOW}pip3 설치 중...${NC}"
    sudo apt install -y python3-pip
fi

# pip3를 pip로 설정
sudo update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# 필요한 Python 패키지 설치
echo -e "${YELLOW}필요한 Python 패키지 설치 중...${NC}"
pip3 install selenium
pip3 install webdriver-manager
pip3 install fake-useragent
pip3 install python-dotenv
pip3 install -r requirements.txt

# 프록시 정보 입력 받기
echo "프록시를 한 줄씩 입력하세요 (형식: http://username:password@ip:port)"
echo "입력을 마치려면 엔터를 두번 입력하세요."
> "$WORK/active_proxies.txt"
while IFS= read -r line; do
    [[ -z "$line" ]] && break
    echo "$line" >> "$WORK/active_proxies.txt"
done

echo -e "${GREEN}프록시 정보가 active_proxies.txt 파일에 저장되었습니다.${NC}"

# 사용자 정보 입력 받기
read -p "이메일을 입력하세요: " APP_USER
read -p "비밀번호를 입력하세요: " APP_PASS

# .env 파일 생성
echo -e "${YELLOW}.env 파일을 생성합니다...${NC}"
echo "APP_USER=$APP_USER" > "$WORK/.env"
echo "APP_PASS=$APP_PASS" >> "$WORK/.env"
echo -e "${GREEN}.env 파일이 생성되었습니다.${NC}"

# 노드실행
python3 bot.py