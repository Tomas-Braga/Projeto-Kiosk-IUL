#!/bin/bash
#export SHOW_DEBUG=1    ## Comment this line to remove @DEBUG statements

###############################################################################
## ISCTE-IUL: Trabalho prático de Sistemas Operativos 2022/2023
##
## Aluno: Nº:93024       Nome:Tomás Rafael Freitas Braga
## Nome do Módulo: stats.sh
## Descrição/Explicação do Módulo: 
## Este módulo tem como objetivo gerar estatísticas sobre as compras efetuadas pelos utilizadores.
## O módulo recebe como argumento um dos seguintes comandos: listar, popular <nr:number> ou histograma.
## Tendo como output o ficheiro stats.txt.
###############################################################################

#Valida o número de argumentos passados, podendo ser 1 ou 2 no caso de ser passado o argumento "popular" 
if [[ ($1 = "listar" || $1 = "histograma") && $# == 1 ]]; then
    ./success 4.1.1
else
    if [[ $1 = "popular" && $# == 2 ]]; then
        ./success 4.1.1
    else
        ./error 4.1.1
        exit 1
    fi
fi

#Valida o argumento "listar" e se os ficheiros relatorio_compras.txt e utilizadores.txt existem,
#listando o nome de cada utilizador e o número de compras que efetuou
if [[ $1 = "listar" && $# == 1 ]]; then
    if [[ -f relatorio_compras.txt ]] && [[ -f utilizadores.txt ]]; then
        cat relatorio_compras.txt | awk -F ":" '{print $3}' | sort -r | uniq -c | while read line; do
            userId=$(echo $line | awk -F " " '{print $2}')
            userPurchases=$(echo $line | awk -F " " '{print $1}')
            userName=$(cat utilizadores.txt | sed -n ${userId}'p' | awk -F ":" '{print $2}')
            if [[ $userPurchases -eq 1 ]]; then
                echo "$userName: $userPurchases compra" >> stats.txt.tmp
            else
                echo "$userName: $userPurchases compras">> stats.txt.tmp
            fi
        done
        sort -t ":" -k 2 -nr  stats.txt.tmp > stats.txt
        rm stats.txt.tmp
        ./success 4.2.1
    else 
        ./error 4.2.1
        exit 1
    fi
fi

#Valida o argumento "popular", se o segundo argumento é um numero inteiro e se o ficheiro relatorio_compras.txt existe,
#listando o nome de cada produto e o número de compras associadas a esse produto. Não podendo o segundo argumento ser superior ao número de categorias compradas
maxPopular="$(cat relatorio_compras.txt | awk -F ":" '{print $1}' | sort -r | uniq -c | wc -l)"
if [[ $1="popular" && $2 =~ ^[0-9]+$ && $2<=$maxPopular ]]; then
    if [[ -f relatorio_compras.txt ]]; then
        cat relatorio_compras.txt | awk -F ":" '{print $1}' | sort -r | uniq -c | while read line; do
            productName=$(echo $line | cut -f2- -d' ')
            prodPurchases=$(echo $line | awk -F " " '{print $1}') 
            if [[ $prodPurchases -eq 1 ]]; then
                echo "$productName: $prodPurchases compra" >> stats.txt.tmp
            else
                echo "$productName: $prodPurchases compras" >> stats.txt.tmp
            fi
        done
        cat stats.txt.tmp
        cat stats.txt.tmp | sort -t':' -k2 -r | head -$2  > stats.txt
        rm stats.txt.tmp
        ./success 4.2.2
    else 
        ./error 4.2.2
        exit 1
    fi
fi

#Valida o argumento "histograma" e se o ficheiro relatorio_compras.txt existe, listando em formato de histograma
#o nome de cada categoria de produto e o número de compras associadas a essa categoria
if [[ $1 = "histograma" ]]; then
    if [[ -f relatorio_compras.txt ]]; then
        cat relatorio_compras.txt | awk -F ":" '{print $2}' | sort -r | uniq -c | while read line; do
            productCategory=$(echo $line | cut -f2- -d' ')
            categoryPurchases=$(echo $line | awk -F " " '{print $1}') 
            for i in $(seq 1 $categoryPurchases); do
                aux="$aux#"
            done
            printf "%-15s %-0s\n" "$productCategory" "$aux" >> stats.txt.tmp
        done
        cat stats.txt.tmp | sed 's/#/*/g' > stats.txt
        rm stats.txt.tmp  
        ./success 4.2.3
    else 
        ./error 4.2.3
        exit 1
    fi
fi
