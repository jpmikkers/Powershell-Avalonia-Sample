using assembly ".\Avalonia.dll"
using assembly ".\Avalonia.Base.dll"
using assembly ".\Avalonia.Controls.dll"
using assembly ".\Avalonia.DesignerSupport.dll"
using assembly ".\Avalonia.Desktop.dll"
using assembly ".\Avalonia.Markup.dll"
using assembly ".\Avalonia.Markup.Xaml.dll"
using assembly ".\Avalonia.Skia.dll"
using assembly ".\Avalonia.Native.dll"
using assembly ".\Avalonia.Win32.dll"
using assembly ".\Avalonia.Themes.Fluent.dll"
#using assembly ".\Avalonia.Themes.Simple.dll"
#using assembly ".\Avalonia.ReactiveUI.dll"
#using assembly ".\Avalonia.Diagnostics.dll"
#using assembly ".\Material.Avalonia.dll"
#using assembly ".\SkiaSharp.dll"

using namespace System
using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.Collections.ObjectModel
using namespace System.Collections
#using namespace System.Diagnostics
#using namespace System.Diagnostics.CodeAnalysis
using namespace System.Globalization
using namespace System.Reactive
using namespace System.Reactive.Linq
using namespace System.Reactive.Subjects
using namespace System.Reactive.Disposables
using namespace System.Windows.Input
using namespace Avalonia
using namespace Avalonia.Animation
using namespace Avalonia.Animation.Easings
using namespace Avalonia.Collections
using namespace Avalonia.Controls
using namespace Avalonia.Controls.ApplicationLifetimes
using namespace Avalonia.Controls.Documents
using namespace Avalonia.Controls.Presenters
using namespace Avalonia.Controls.Primitives
using namespace Avalonia.Controls.Shapes
using namespace Avalonia.Controls.Templates
using namespace Avalonia.Data
using namespace Avalonia.Interactivity
using namespace Avalonia.Input
using namespace Avalonia.Input.TextInput
using namespace Avalonia.Layout
using namespace Avalonia.Markup.Xaml
using namespace Avalonia.Markup.Xaml.Parsers
using namespace Avalonia.Markup.Xaml.Converters
using namespace Avalonia.Markup.Xaml.MarkupExtensions
using namespace Avalonia.Markup.Xaml.MarkupExtensions.CompiledBindings
using namespace Avalonia.Markup.Xaml.Styling
using namespace Avalonia.Markup.Xaml.Templates
using namespace Avalonia.Media
using namespace Avalonia.Metadata
using namespace Avalonia.Platform
using namespace Avalonia.Styling
using namespace Avalonia.Themes.Fluent
#using namespace Avalonia.Themes.Simple
using namespace Avalonia.Threading
using namespace Avalonia.VisualTree
using namespace Avalonia.Platform
using namespace Avalonia.AppBuilder
using namespace Avalonia.Native
using namespace Avalonia.Desktop
using namespace Avalonia.Win32
using namespace Avalonia.Skia
using namespace System.Reflection

#requires -Version 7.2
Set-StrictMode -Version 3

$emptyArgs = [string[]]@()

$builder=[Avalonia.AppBuilder]::Configure[Avalonia.Application]()
$builder=[AppBuilderDesktopExtensions]::UsePlatformDetect($builder)

# hacky solution, set private static field 's_setupWasAlreadyCalled' to false, otherwise this will prevent us from running the script multiple times from powershell
$hackPrivateFlag=$builder.GetType().BaseType.GetField("s_setupWasAlreadyCalled",[BindingFlags]::NonPublic + [BindingFlags]::Static ) | Select-Object -First 1
if($null -ne $hackPrivateFlag)
{
    $hackPrivateFlag.SetValue($null,$false)
}

[ClassicDesktopStyleApplicationLifetime]$lifetime=[ClassicDesktopStyleApplicationLifetime]::new()
$lifetime.ShutdownMode = [ShutdownMode]::OnMainWindowClose      # [ShutdownMode]::OnLastWindowClose
$lifetime.Args = $emptyArgs

$builder=$builder.AfterSetup({ 
    # magic because I have no clue why the uri bit is needed.
    $magic = "avares://$([Avalonia.Themes.Fluent.FluentTheme].Assembly.GetName())"
	$theme = [Avalonia.Themes.Fluent.FluentTheme]::new([uri]::new($magic))
	$theme.Mode = [Avalonia.Themes.Fluent.FluentThemeMode]::Light
    $builder.Instance.Styles.Add($theme)
})

$builder=$builder.AfterSetup({ 
    $builder.Instance.Name = "PowershellAvalonia"
})

try {
    $builder=$builder.SetupWithLifetime($lifetime)

    $label = [Label]::new()
    $label.Content = "Click buttons below"
    $label.HorizontalAlignment = [HorizontalAlignment]::Center
    $label.FontSize = 30

    $button1 = [Button]::new()
    $button1.Content = "Button 1"
    $button1.HorizontalAlignment = [HorizontalAlignment]::Center

    $button2 = [Button]::new()
    $button2.Content = "Button 2"
    $button2.HorizontalAlignment = [HorizontalAlignment]::Center

    $stackpanel = [StackPanel]::new()
    $stackpanel.HorizontalAlignment = [HorizontalAlignment]::Center
    $stackpanel.VerticalAlignment = [VerticalAlignment]::Center
    $stackpanel.Orientation = [Orientation]::Vertical
    $stackpanel.Spacing = 2.0
    $stackpanel.Children.Add($label)
    $stackpanel.Children.Add($button1)
    $stackpanel.Children.Add($button2)
    
    $button1.AddHandler([Button]::ClickEvent,[Action[object,object]]{ 
        param($component,$evargs)
        $label.Content = "You clicked button 1"
    })
    
    $button2.AddHandler([Button]::ClickEvent,[Action[object,object]]{ 
        param($component,$evargs)
        $label.Content = "You clicked button 2"
    })
    
    $window = [Window]::new()
    $window.Title = "Hello from PowerShell"
    $window.Content = $stackpanel
    $window.Width = 300
    $window.Height = 200

    $lifetime.MainWindow = $window
    $lifetime.Start($emptyArgs)    
}
finally {
    $lifetime.Dispose()
}
