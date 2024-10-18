# Patrulhamento por óleo
Repositório com os códigos referentes ao Trabalho de Conclusão de Curso da aluna Lívia de Maria Calado Machado Soares.

# Rodar Repositório

Para iniciar o processo de execução deste trabalho, é necessário que o usuário tenha em seu computador instalado: 
- Matlab
- Terminal do Anaconda - miniconda


Com esses dois aplicativos instalados, os seguintes passos serão seguidos: 
- Faça o DownLoad do seguinte repositório [PyGnome](https://github.com/NOAA-ORR-ERD/PyGnome) , descompacte a pasta e adicione na pasta deste repositório 
-  Crie um ambiente virtual pelo terminal do anaconda usando o seguinte comando:

` $ conda create -n gnome python=3.12 `

- Adicione o canal "conda forge" para adiquirir algumas bibliotecas

` conda config --add channels conda-forge`

- Com o ambiente do gnome criado, ative o ambiente

` conda activate gnome`

- Instale os requerimentos do PyGnome. Vá até a pasta que você colocou a pasta do PyGnome, pelo terminal do anaconda. Agora entre na pasta "py_gnome" e rode o seguinte ocmando:

` conda install --file conda_requirements.txt `

- Ainda nesta pasta, rode o PyGnome, com o seguinte comando: 

`python setup setup_legacy `


Após todos os comandos, o pygnome deverá estar rodando corretamente no ambiente virtual. Agora é necessário fazer a ativação do ambiente virtual no código do matlab.

# Ativação do ambiente virtual

Para realizar a ativação, o usuário deverá procurar a pasta no qual o ambeinte virtual está salvo, por exemplo:

` 'C:\Users\lilic\miniconda3\envs\gnome\python.exe' `

Após isso, copie esse caminho e vá para a pasta "patrol-for-oil" e abra o arquivo "gnome_sim.m". Dentro dele procule a linha de código que conterá: 

` python_cmd = 'C:\Users\lilic\miniconda3\envs\gnome\python.exe'; % Windows`

Modifique o caminho presente pelo caminho do seu ambiente virtual

# Rodando aplicação

Por fim, para rodar a aplicação, entre na pasta patrol-for-oil, pelo matlab. Em seguida selecione a pasta kml2struct com o botão direito e selecione a opção "Add to path" e em seguida "Selected Folders".

Finalmente, vá para o arquvio "manager.m" e aperte para rodar a aplicação. Ao final, espera-se rodar pelo menos 100 vezes para gerar uma comparação entre o random walk e a política de patrulhamento atual. 
