param(
    [ValidateSet('run', 'test', 'apk')]
    [string]$Target = 'run'
)

$envFile = 'env/local.json'

if (!(Test-Path $envFile)) {
    Write-Host "Missing $envFile" -ForegroundColor Red
    Write-Host 'Create it first with:' -ForegroundColor Yellow
    Write-Host '  Copy-Item env/local.example.json env/local.json'
    exit 1
}

switch ($Target) {
    'run' {
        flutter run --dart-define-from-file=$envFile
    }
    'test' {
        flutter test --dart-define-from-file=$envFile
    }
    'apk' {
        flutter build apk --dart-define-from-file=$envFile
    }
}
