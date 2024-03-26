#!/bin/bash
#export SHOW_DEBUG=1    ## Comment this line to remove @DEBUG statements

###############################################################################
## ISCTE-IUL: Trabalho prático de Sistemas Operativos 2022/2023
##
## Aluno: Nº:93024       Nome:Tomás Rafael Freitas Braga 
## Nome do Módulo: menu.sh
## Descrição/Explicação do Módulo: 
## Este scrpit não recebendo argumento é responsável por apresentar o menu principal 
## do Kiosk-IUL e por chamar os scripts que executam as funcionalidades do programa.
###############################################################################
 
#Apresentação do menu
while :; do
    echo ""
    echo "MENU:"
    echo "1: Regista/Atualiza saldo utilizador"
    echo "2: Compra produto"
    echo "3: Reposição de stock"
    echo "4: Estatísticas"
    echo "0: Sair"
    echo ""
    echo -n "Opção: " 
    read opcao

    #Validação da opção como um número inteiro entre 0 e 4 (inclusive)
    if [[ "$opcao" =~ ^[0-4]+$ ]]; then
        ./success 5.2.1 $opcao

        #Validação da opção 0 (sair)
        if [[ "$opcao" == 0 ]]; then
            ./success 5.2.2.4
            exit 0
        fi

        #Validação da opção 1 (regista/atualiza saldo utilizador)
        if [[ "$opcao" == 1 ]]; then
            echo ""
            echo "Regista utilizador / Atualiza saldo utilizador:"
            echo -n "Indique o nome do utilizador: "
            read nome
            echo -n "Indique a senha do utilizador: "
            read senha
            echo -n "Para registar o utilizador, insira o NIF do utilizador: "
            read nif
            echo -n "Indique o saldo a adicionar ao utilizador: "
            read saldo
            ./regista_utilizador.sh "$nome" "$senha" "$saldo" "$nif"
            ./success 5.2.2.1
        fi

        #Validação da opção 2 (compra produto)
        if [[ "$opcao" == 2 ]]; then
            ./compra.sh
            ./success 5.2.2.2
        fi
        
        #Validação da opção 3 (reposição de stock)
        if [[ "$opcao" == 3 ]]; then
            ./refill.sh
            ./success 5.2.2.3
        fi
        
        #Validação da opção 4 (estatísticas)
        if [[ "$opcao" == 4 ]]; then
            echo ""
            echo "Estatísticas:"
            echo "1: Listar utilizadores que já fizeram compras"
            echo "2: Listar os produtos mais vendidos"
            echo "3: Histograma de vendas"
            echo "0: Voltar ao menu principal"
            echo ""
            echo -n "Sub-Opção: "
            read subopcao
            
            #Validação da sub-opção como um número inteiro entre 0 e 3 (inclusive)
            if [[ "$subopcao" =~ ^[0-3]+$ ]]; then

                #Validação da sub-opção 1 (listar utilizadores que já fizeram compras)
                if [[ "$subopcao" == 1 ]]; then
                    ./stats.sh "listar"
                    ./success 5.2.2.4
                fi

                #Validação da sub-opção 2 (listar os produtos mais vendidos)
                if [[ "$subopcao" == 2 ]]; then
                    echo ""
                    echo "Listar os produtos mais vendidos:"
                    echo -n "Indique o número de produtos mais vendidos a listar: "
                    read n
                    ./stats.sh "popular" $n
                    ./success 5.2.2.4
                fi
            
                #Validação da sub-opção 3 (histograma de vendas por categoria)
                if [[ "$subopcao" == 3 ]]; then
                    ./stats.sh "histograma"
                    ./success 5.2.2.4
                fi
            else
                ./error 5.2.2.4
            fi
        fi
    else
        ./error 5.2.1 $opcao
    fi
done
