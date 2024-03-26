#!/bin/bash
#export SHOW_DEBUG=1    ## Comment this line to remove @DEBUG statements

###############################################################################
## ISCTE-IUL: Trabalho prático de Sistemas Operativos 2022/2023
##
## Aluno: Nº:93024       Nome:Tomás Rafael Freitas Braga
## Nome do Módulo: regista_utilizador.sh
## Descrição/Explicação do Módulo:
## O script regista_utilizador.sh recebe como argumentos o nome do utilizador, a password, o saldo e o número de contribuinte.
## O script tem como objetivo registar um utilizador no sistema, caso este não exista, ou adicionar saldo ao utilizador caso este já exista.
###############################################################################

#Validar o número de argumentos passados ao script (3 ou 4)
if [[ $# == 3 || $# == 4 ]]; then
    ./success 1.1.1
else
    ./error 1.1.1
    exit 1
fi

#Valida se o campo do nome de utilizador corresponde exatamente a um utilizador do tigre
if [[ $(cat /etc/passwd | awk -F "[:,]" '{print $5}' | grep -x "$1") ]]; then
    ./success 1.1.2
else
    ./error 1.1.2
    exit 1
fi

#Validar se o saldo é um numero inteiro positivo (>=0)
if [[ $3 =~ ^[0-9]+$ ]]; then
    ./success 1.1.3
else
    ./error 1.1.3
    exit 1
fi

#Validar se o numero de contribuinte corresponde ao quarto argumento e se é um numero inteiro de 9 digitos
if [[ $# == 4 && -n $4 ]]; then
    if [[ "$4" =~ ^[0-9]{9}$ ]]; then
        ./success 1.1.4
    else
        ./error 1.1.4
        exit 1
    fi
fi

#Verificar se o ficheiro utilizadores.txt existe, se não existir cria o ficheiro utilizadores.txt
if [[ -f utilizadores.txt ]]; then
    ./success 1.2.1
else
    ./error 1.2.1
    if touch utilizadores.txt; then
        ./success 1.2.2
    else
        ./error 1.2.2
        exit 1
    fi
fi

#Verificar se o utilizador já existe no ficheiro utilizadores.txt
if [[ $(cat utilizadores.txt | grep "$1") ]]; then
    ./success 1.2.3

    #valida se o argumento passado como password corresponde à password do utilizador
    if [[ $(cat utilizadores.txt | grep "$1" | awk -F ":" '{print $3}') == "$2" ]]; then
        ./success 1.3.1
    else
        ./error 1.3.1
        exit 1
    fi
    
    #Adicionar saldo ao utilizador passado como argumento, guardando a linha antiga do utilizador e transformando-a 
    #numa nova linha com o novo saldo
    balance=$(cat utilizadores.txt | grep "$1" | awk -F ":" '{print $6}')
    newBalance=$(( $balance+$3 ))

    OldLine=$(awk -F: '{ if ($2 == "'"$1"'") print $0; }' utilizadores.txt);
    NewLine="$(echo $OldLine | awk -F: -v OFS=: '{$6="'"$newBalance"'"; print}')";   

    sed -i "s/$OldLine/$NewLine/" utilizadores.txt

    if [[ $? == 0 ]]; then
        ./success 1.3.2 $newBalance
    else
        ./error 1.3.2
        exit 1
    fi
else
    ./error 1.2.3
    if [[ $# -eq 4 ]]; then
        ./success 1.2.4
    else 
        ./error 1.2.4
        exit 1
    fi

    #Caso o utilizador não exista na base de dados este é adicionado o utilizador ao ficheiro utilizadores.txt 
    #(se não existir coloca id=1, se existir coloca o id com seguinte valor ao último id presente no ficheiro utilizadores.txt)
    if [[ $(cat utilizadores.txt | wc -l) -eq 0 ]]; then
        ./error 1.2.5
        idUtilizador=1
    else
        idUtilizador=$(( $(cat utilizadores.txt | wc -l) + 1 ))
        ./success 1.2.5 $idUtilizador
    fi

    #Gerar o email do utilizador utilizando o primeiro nome e o ultimo nome (é obrigatório o utilizador possuir dois nomes)
    firstName=$(echo $1 | awk -F "[ ]" '{print tolower($1)}')
    lastName=$(echo $1 | awk '{print tolower($NF)}')
    if [[ -n $lastName && $lastName != $firstName ]]; then
        email="$firstName.$lastName@kiosk-iul.pt"
        ./success 1.2.6 $email
    else
        ./error 1.2.6
        exit 1
    fi

    #Adicionar o utilizador ao ficheiro utilizadores.txt
    echo "$idUtilizador:$1:$2:$email:$4:$3" >> utilizadores.txt
    if [ $? -eq 0 ]; then
        ./success 1.2.7 "$idUtilizador:$1:$2:$email:$4:$3" 
    else
        ./error 1.2.7
        exit 1
    fi
fi 

#Cria um ficheiro igual ao utilizadores.txt, mas com o saldo por ordem decrescente 
cat utilizadores.txt | sort -t ":" -k 6 -nr > saldos-ordenados.txt
if [ $? -eq 0 ]; then
  ./success 1.4.1
else
  ./error 1.4.1
  exit 1
fi
