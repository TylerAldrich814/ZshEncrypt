#!/bin/zsh
#
# ->> Encrypting and Decrypting Files Using OpenSSL
#   - Currently utilizing the 'aes-256-cbc pbkdf3' encryption algorithm.
#
#   - To encrypt a file, use the command 'encrypt $FILENAME':
#     $ encrypt my_secrets.sec
#   - OpenSSL will then prompt you to enter a password.
#   - Upon successful encryption, 'my_secrets.sec' will be replaced
#     with its encrypted counterpart, 'my_secrets.sec.enc'.
#
#   - Decrypting Files: The 'decrypt' function requires one input variable,
#     the path to the encrypted file. This will decrypt the file and then open
#     the decrypted file's contents in your editor of choice
#     (default editor is Neovim).
#   - After exiting the editor, the script compares timestamps: one from
#     file creation (before) and one from when you exit the editor (after).
#     A discrepancy between these timestamps indicates that the file
#     may have been edited (saved within the editor).
#   - Should there be any changes, the script triggers the functions to
#     re-encrypt the file, subsequently prompting you to enter a new password.
#     Upon successful re-encryption, the function will remove the unencrypted file.
#
#     -- GLOBAL VARIABLES

## Opening a file in a editor MUST take 1 argument, i.e the file path
EDITOR="nvim" # | "vim" | "nano" | "code" | ect..

## To automatically remove the raw file after successful encryption
REMOVE_AFTER_ENCRYPTION=1

## To automatically re-encrypt an edited decrypted file in your editor.
REENCRYPT_AFTER_SAVE=1

## !WARNING: If you change the iteration while you have encrypted files.
#            You WILL not be able to decrypt them back without the original
#            iterations you used when you encrpted the file!!!!
ITERATIONS=10000

# My Functions
encrypt(){
  IN_FILE=$1

  OUT_FILE="${IN_FILE}.enc"

  __color_openssl enc \
      -aes-256-cbc \
      -salt \
      -pbkdf2 \
      -iter ${ITERATIONS} \
      -in ${IN_FILE} \
      -out ${OUT_FILE}


  if [ -f "$OUT_FILE" ]; then
    if [ $REMOVE_AFTER_ENCRYPTION -ne 1 ]; then
      return 0
    fi

    _echo_green "\nEncryption of ${IN_FILE} Successful: Removing Raw File"
    rm $IN_FILE
  else
    _echo_red "Something unexpected happened. Failed to encrypt ${IN_FILE}"
  fi
}

decrypt(){
  IN_FILE=$1
  OUT_FILE=${IN_FILE[1,-5]}

  __color_openssl enc -d \
      -aes-256-cbc \
      -salt \
      -pbkdf2 \
      -iter ${ITERATIONS} \
      -in ${IN_FILE} \
      -out ${OUT_FILE}

  # Newly created decrypted files creation time
  mod_time_before=$(stat -f "%m" $OUT_FILE)

  $EDITOR ${OUT_FILE}

  if [ $REENCRYPT_AFTER_SAVE -ne 1 ]; then
    return 0
  fi

  # Newly create decrypted files possible edit time
  mod_time_after=$(stat -f "%m" $OUT_FILE)

  mod_time_diff=$((mod_time_after - mod_time_before))

  _echo_yellow "Time Difference ${mod_time_diff}"

  if [ "$mod_time_diff" -gt 0 ]; then
    _echo_green "\nFile Change Difference Detected: Re-encrypting file now"
    __color_openssl enc \
        -aes-256-cbc \
        -salt \
        -pbkdf2 \
        -iter ${ITERATIONS} \
        -in ${IN_FILE} \
        -out ${OUT_FILE}
  fi

  if [ $REMOVE_AFTER_ENCRYPTION -ne 1 ]; then
    return 0
  fi

  _echo_yellow "Removing Decrypted File"
  rm ${OUT_FILE}
}

## -- Local Functions
__color_openssl(){
  exit_code=$?

  if [ $exit_code -ne 0 ]; then
    echo -ne "\e[33m"
    openssl "$@"
  else
  echo -ne "\e[32m"
    openssl "$@"
  fi

  # Capture the exit code of openssl
  local exit_code=$?

  # Reset text color back to default
  echo -ne "\e[0m"

  # Return the original exit code of the openssl command
  return $exit_code
}

_echo_red(){
  echo "  -  \e[31m$1\e[0m"
}
_echo_green(){
  echo "  -  \e[32m$1\e[0m"
}
_echo_yellow(){
  echo "  -  \e[33m$1\e[0m"
}
_echo_blue(){
  echo "  -  \e[34m$1\e[0m"
}
_echo_reset(){
  echo "\e[0m"
}
