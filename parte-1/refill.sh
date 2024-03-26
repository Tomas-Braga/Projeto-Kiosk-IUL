#!/bin/bash
#export SHOW_DEBUG=1    ## Comment this line to remove @DEBUG statements

###############################################################################
## ISCTE-IUL: Trabalho prático de Sistemas Operativos 2022/2023
##
## Aluno: Nº:93024       Nome:Tomás Rafael Freitas Braga
## Nome do Módulo: refill.sh
## Descrição/Explicação do Módulo: 
## Este script não recebe nenhum argumento e tem como objetivo atualizar o stock dos produtos no ficheiro produtos.txt com os valores do ficheiro reposicao.txt.
## Caso o stock de um produto seja superior ao seu stock máximo, o stock do produto é atualizado para o seu stock máximo.
###############################################################################

#Verificar se o ficheiro produtos.txt e o ficheiro reposicao.txt existem
if [ -f produtos.txt ] && [ -f reposicao.txt ]; then
    ./success 3.1.1
else
    ./error 3.1.1
fi

#Verifica se a terceira culuna do ficheiro reposicao.txt é um numero inteiro
if [[ $(cat reposicao.txt | awk -F ":" '$NF !~ /^[0-9]+$/ {print}' | wc -l) == 0 ]]; then
    ./success 3.1.2
else
    ./error 3.1.2 "$(awk -vORS=', ' -F ":" '$NF ~ /^[0-9]+$/ {print $1}' reposicao.txt)"
    exit 1
fi

#Cria o ficheiro produtos-em-falta.txt com os produtos que estão em falta 
echo -e "**** Produtos em falta em $(date +%F) ****\n$(cat produtos.txt | awk -F ":" '$4 < $5 {print $1":", $5 - $4" unidades"}')" > produtos-em-falta.txt
if [[ $? -eq 0 ]]; then
    ./success 3.2.1
else
    ./error 3.2.1
    exit 1
fi

#Atualizar o stock dos produtos no ficheiro produtos.txt com os valores do ficheiro reposicao.txt  
cat produtos.txt | while read line; do
    produto=$(echo $line | awk -F ":" '{print $1}')
    stock=$(echo $line | awk -F ":" '{print $4}')
    maxStock=$(echo $line | awk -F ":" '{print $5}')
    reposicao=$(cat reposicao.txt | grep "$produto" | awk -F ":" '{print $3}')
    if [[ -n $reposicao ]]; then
        newStock=$(($stock + $reposicao))
        if [[ $newStock -ge $maxStock ]]; then
            newStock=$(cat produtos.txt | grep "$produto" | awk -F ":" '{print $5}')
        fi
        OldLine=$(awk -F: '{ if ($1 == "'"$produto"'") print $0; }' produtos.txt);
        NewLine="$(echo $OldLine | awk -F: -v OFS=: '{$4="'"${newStock}"'"; print}')";
        sed -i "s/$OldLine/$NewLine/" produtos.txt
    fi
done

if [[ $? -eq 0 ]]; then
    ./success 3.2.2
else
    ./error 3.2.2
    exit 1
fi