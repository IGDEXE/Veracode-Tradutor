# Função para fazer as traduções
function Traduzir {
    param (
        [parameter(position=0,Mandatory=$True)]
        $texto,
        [parameter(position=1)]
        $idiomaAlvo = "pt"
    )

    # Utiliza a API do Google para traduzir
    Try {
        $Uri = “https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$($idiomaAlvo)&dt=t&q=$texto”
        $Response = Invoke-RestMethod -Uri $Uri -Method Get
        # Retorna o valor traduzido
        $traducao = $Response[0].SyncRoot | foreach { $_[0] }
        return $traducao
    }
    Catch {
        # Recebe o erro
        $ErrorMessage = $_.Exception.Message # Recebe o erro
        # Exibe a mensagem de erro
        Write-Host "Erro ao traduzir"
        Write-host $ErrorMessage
    }
}

# Função para criar novas credenciais
function New-VeracodeCredentials {
    param (
        [parameter(position=0,Mandatory=$True)]
        $veracodeID,
        [parameter(position=1,Mandatory=$True)]
        $veracodeAPIkey
    )
    # Valida se a pasta da Veracode existe
    $pastaCredenciais = "$env:USERPROFILE\.veracode\"
    $existe = Test-Path -Path "$pastaCredenciais"
    if ($Existe -eq $false) {
        # Cria a pasta
        New-Item -ItemType "directory" -Path "$pastaCredenciais"
    }
    # Faz a criação do arquivo
    $caminhoArquivo = "$pastaCredenciais\credentials"
    $arquivoCredenciais = "[default]","veracode_api_key_id = $veracodeID","veracode_api_key_secret = $veracodeAPIkey"
    Add-Content -Path $caminhoArquivo -Value $arquivoCredenciais
}

# Função para pegar as credenciais com base no arquivo de configuração do IDE Scan/Greenlight
function Get-VeracodeCredentials {
    # Pega as credenciais do arquivo da Veracode
    $arquivoCredenciais = Get-Content -Path "$env:USERPROFILE\.veracode\credentials"
    # Recebe os valores
    $VeracodeID = $arquivoCredenciais[1].Replace("veracode_api_key_id = ","")
    $APIKey = $arquivoCredenciais[2].Replace("veracode_api_key_secret = ","")
    # Configura a saida
    $veracodeCredenciais = $VeracodeID,$APIKey
    return $veracodeCredenciais
}