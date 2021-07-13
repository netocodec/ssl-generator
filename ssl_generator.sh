#!/bin/bash

clear

application_title="SSL Generator V1.0"
quit_mode=0

key_id="$(date +%Y_%m_%d_%H_%M)"

trap 'clean_up' SIGINT
trap 'clean_up' SIGQUIT
trap 'clean_up' 0

clean_up(){
	quit_mode=1
	rm *.log
	clear
}

done_message(){
	dialog --title "$application_name" --msgbox "Do not loose any of these files! All files are generated with date type: $key_id" 0 0
}

check_dependencies(){
	echo "Checking required dependencies..."
	echo ""
	existdep="`which dialog`"

	if [ ${#existdep} -eq 0 ];then
		echo "Missing some dependencies!"
		echo "Installing depedencies for you!"
		echo ""
		sudo apt -y install dialog
	fi
}

generate_cert_file(){
	dialog --title "$application_title" --gauge "Generate SSL Certificate File..." 0 0 90 &
	openssl x509 -req -days 365 -in csr_$key_id.csr -signkey private_key_$key_id.pem -out ssl_certificate_$key_id.crt -passin pass:$cert_password
}

generate_csr_file(){
	dialog --title "$application_title" --gauge "Generate CSR File..." 0 0 70 &
	openssl req -new -newkey rsa:2048 -nodes -keyout private_key_$key_id.pem -out csr_$key_id.csr -passin pass:$cert_password
}

generate_pub_key(){
	dialog --title "$application_title" --gauge "Generate Public Key File..." 0 0 40 &
	openssl rsa -in private_key_$key_id.pem -outform PEM -pubout -out public_key_$key_id.pem -passin pass:$cert_password > pub.log
}

generate_priv_key(){
	dialog --title "$application_title" --gauge "Generate Private Key File..." 0 0 10 &
	openssl genrsa -$version -out private_key_$key_id.pem -passout pass:$cert_password 2048 > priv.log
}

generate_random_keys(){
	dialog --title "$application_title" --gauge "Generate Private Key File..." 0 0 10 &
	openssl genrsa -out private_key_$key_id.pem 2048
	dialog --title "$application_title" --gauge "Generate Public Key File..." 0 0 50 &
	openssl ecparam -genkey -name secp384r1 -out server_$key_id.key
	dialog --title "$application_title" --gauge "Generate Certificate File..." 0 0 90 &
	openssl req -new -x509 -sha256 -key server_$key_id.key -out server_$key_id.crt -days 3650
}


ask_cert_password(){
	cert_password=$( dialog --stdout --title "$application_title" --passwordbox "Insert the password you want for the key:" \
		0 0 )

	if [ "$cert_password" == "" ]; then
		clean_up
	else
		fname=my_cert_password_"$(date +%Y_%m_%d_%H_%M)".txt
		echo "$cert_password" > $fname
	fi

}

select_cert_type(){
	version=$( dialog --stdout --title "$application_title" --radiolist "Select the encryption version." \
		0 0 0 \
		aes256 'AES 256' on \
		aes192 'AES 192' off \
		aes128 'AES 128' off )

	if [ "$version" == "" ]; then
		clean_up
	else
		ask_cert_password
	fi
}

init_menu(){
	option=$( dialog --stdout --title "$application_title" --menu "Select an option." \
		0 0 0 \
		0 'Generate Public Key' \
		1 'Generate Private Key' \
		2 'Generate SSL Certificate' \
		3 'Generate Random Key and Certificate' \
		4 'Exit Menu' )

	if [ "$option" != "" ]; then
		case $option in
			[0])
			select_cert_type
			generate_priv_key
			generate_pub_key
			;;

			[1])
			select_cert_type
			generate_priv_key
			;;

			[2])
			select_cert_type
			generate_priv_key
			generate_csr_file
			generate_cert_file
			;;

			[3])
			generate_random_keys
			;;

			[4])
			clean_up
			;;
		esac

		if [ $quit_mode -eq 0 ];then
			done_message
		fi
	fi
	clean_up
}



# Init Sector

check_dependencies
init_menu



