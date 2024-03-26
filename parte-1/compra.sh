#!/bin/bash
#export SHOW_DEBUG=1    ## Comment this line to remove @DEBUG statements

###############################################################################
## ISCTE-IUL: Trabalho prático de Sistemas Operativos 2022/2023
##
## Aluno: Nº:93024       Nome:Tomás Rafael Freitas Braga 
## Nome do Módulo: compra.sh
## Descrição/Explicação do Módulo: 
## Este script tem como objetivo permitir a compra de produtos por parte de um utilizador.
## O script irá apresentar uma lista de produtos com stock superior a 0 e o utilizador terá de escolhe um produto a comprar, autenticando-se na plataforma.
###############################################################################

#Validar se o ficheiro utilizadores.txt e produtos.txt existem 
if [[ -f utilizadores.txt && -f produtos.txt ]]; then
    ./success 2.1.1
else
    ./error 2.1.1
    exit 1
fi

#É apresentado uma lista de produtos com stock superior a 0 e o utilizador terá de escolhe um produto. Para este fim foi criado um ficheiro 
#auxiliar com os produtos disponiveis (availableProducts.txt)
if [[ -s produtos.txt ]]; then
    aux=$(cat produtos.txt | awk -F ":" '$4 != 0 {print $1, $3}' | wc -l)
    cat produtos.txt | awk -F ":" '$4 != 0 {print}' > availableProducts.txt
    for (( i=1; i<=$aux; i++ )); do
        echo "$i: $(cat produtos.txt | awk -F ":" '$4 != 0 {print $1}' | head -$i | tail -1): $(cat produtos.txt | awk -F ":" '$4 != 0 {print $3}' | head -$i | tail -1) EUR"
    done
else
    ./error 2.1.2
    exit 1
fi
echo "0: Sair" 
echo ""
echo -n "Insira a sua opção: "
read n

#Valida a opção 0. Opção 0 sai do script
if [[ "$n" =~ 0 ]]; then
    ./success 2.1.2
    exit 0
fi    

#Valida se o número inserido é um numero inteiro e se corresponde a um número no intervalo de produtos disponiveis
if [[ "$n" =~ ^[0-9]+$ ]]; then
    if [[ "$n" -ge 1 && "$n" -le $aux ]]; then
        ./success 2.1.2 "$(cat availableProducts.txt | awk -F ":" '$4 != 0 {print $1}' | head -$n | tail -1)"
    else 
        ./error 2.1.2
        exit 1
    fi
else
    ./error 2.1.2
    exit 1 
fi 


#Valida se o ID é um número e se existe no ficheiro utilizadores.txt, não podendo ser passado como argumento valores negativos nem 
#superiores ao ultimo ID do ficheiro utilizadores.txt
echo -n "Insira o ID do seu utilizador: "
read iduser
if [[ "$iduser" =~ ^[0-9]+$ ]]; then
    if [[ $iduser -ge 1 && $iduser -le $(cat utilizadores.txt | wc -l) ]]; then
        ./success 2.1.3 "$(cat utilizadores.txt | head -$iduser | tail -1 | awk -F ":" '{print $1}')"
    else 
        ./error 2.1.3
        exit 1
    fi
else
    ./error 2.1.3
    exit 1
fi

#valida se a senha corresponde ao id do utilizador no ficheiro utilizadores.txt
echo -n "Insira a senha do seu utilizador: "
read senha
if [[ "$senha" == $(cat utilizadores.txt | head -$iduser | tail -1 | awk -F ":" '{print $3}') ]]; then
    ./success 2.1.4
else
    ./error 2.1.4
    exit 1
fi

#Valida se o utilizador tem saldo suficiente para comprar o produto e se sim regista a compra no ficheiro relatorio_compras.txt
userBalance=$(cat utilizadores.txt | head -$iduser | tail -1 | awk -F ":" '{print $6}')
prodPrice=$(cat availableProducts.txt | head -$n | tail -1 | awk -F ":" '{print $3}')
if [[ "$userBalance" -ge "$prodPrice" ]]; then
    ./success 2.2.1 "$prodPrice" "$userBalance"
   
    #Atualiza o saldo do utilizador no ficheiro utilizadores.txt, calculando o novo saldo e transformando o saldo da linha antigo
    #em uma nova linha com o novo saldo
    newBalance=$(( "$userBalance" - "$prodPrice" ))
    OldLine=$(awk -F: '{ if ($1 == "'"$iduser"'") print $0; }' utilizadores.txt);
    NewLine="$(echo $OldLine | awk -F: -v OFS=: '{$6="'"$newBalance"'"; print}')";
    sed -i "s/$OldLine/$NewLine/" utilizadores.txt
    if [[ $? -eq 0 ]]; then
        ./success 2.2.2
    else
        ./error 2.2.2
        exit 1
    fi

    #Atualiza o stock do produto no ficheiro produtos.txt, transformando a linha antiga em uma nova linha com o novo stock 
    prodStock=$(cat availableProducts.txt | head -$n | tail -1 | awk -F ":" '{print $4}')
    prodName=$(cat availableProducts.txt | head -$n | tail -1 | awk -F ":" '{print $1}')
    OldLine=$(awk -F: '{ if ($1 == "'"$prodName"'") print $0; }' produtos.txt);
    NewLine="$(echo $OldLine | awk -F: -v OFS=: '{$4="'"$((${prodStock} - 1))"'"; print}')";
    sed -i "s/$OldLine/$NewLine/" produtos.txt
    if [[ $? -eq 0 ]]; then
        ./success 2.2.3
    else
        ./error 2.2.3
        exit 1
    fi

    #Regista a compra no ficheiro relatorio_compras.txt com o nome do produto, a categoria do produto, o id do utilizador e a data da compra
    categ=$(cat availableProducts.txt | head -$n | tail -1 | awk -F ":" '{print $2}')
    echo "$prodName:$categ:$iduser:$(date +%F)" >> relatorio_compras.txt
    if [[ $? -eq 0 ]]; then
        ./success 2.2.4
    else
        ./error 2.2.4
        exit 1
    fi

    #Cria o ficheiro lista-compras-utilizador.txt com o nome do utilizador, a data da compra e a lista de compras do utilizador
    userName=$(cat utilizadores.txt | head -$iduser | tail -1 | awk -F ":" '{print $2}')
    echo -e "**** $(date +%F): Compras de $userName ****\n$(cat relatorio_compras.txt | sed 's/:/,/g' | awk -F "," '$3 == "'"$iduser"'" {print $1",", $4}')" > lista-compras-utilizador.txt
    if [[ $? -eq 0 ]]; then
        ./success 2.2.5
        exit 0
    else
        ./error 2.2.5
        exit 1
    fi
else
    ./error 2.2.1 "$prodPrice" "$userBalance"
    exit 1
fi
   