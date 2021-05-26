#!/bin/bash

clear

application_title="SSL Generator V1.0"
quit_mode=0

key_id="$(date +%Y_%m_%d_%H_%M)"

clean_up(){
	quit_mode=1
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
echo "Hello"
}

generate_csr_file(){
echo "Hello"
}

generate_pub_key(){
	openssl rsa -in private_key_$key_id.pem -outform PEM -pubout -out public_key_$key_id.pem -passin pass:$cert_password
}

generate_priv_key(){
	openssl genrsa -$version -out private_key_$key_id.pem -passout pass:$cert_password 2048
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
		3 'Exit Menu' )

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
			echo "HEHEHEH"
			;;

			[3])
			clean_up
			;;
		esac

		if [ $quit_mode -eq 0 ];then
			done_message
		fi
	else
		clean_up
	fi
}



# Init Sector

check_dependencies
init_menu



