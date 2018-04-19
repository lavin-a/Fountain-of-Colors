Add-Type -AssemblyName System.Drawing

$image = [Drawing.Image]::FromFile(-join($env:APPDATA,'\Microsoft\Windows\Themes\TranscodedWallpaper'))
$ms = New-Object IO.MemoryStream
$image.Save($ms, $image.RawFormat)
$image = [Convert]::ToBase64String($ms.ToArray())

$script = Get-Content (-join((Get-Item -Path ".\").FullName, '\@Resources\color-thief.min.js'))
$js = @"
  $script;
  var colorThief = new ColorThief(), img = new Image();
  img.src = "data:image/jpeg;base64, $image";
  document.body.innerHTML = colorThief.getPalette(img, 4).join('|');
"@

$ie = New-Object -COM InternetExplorer.Application
$ie.Navigate("about:blank")
$ie.document.parentWindow.execScript("$js", "javascript")
$ie.document.body.innerHTML
$ie.Quit()