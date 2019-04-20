$ErrorActionPreference = "Stop"

# Lazy $PSScriptRoot shortcut so it works while debugging in a VS Code session
if (-not $PSScriptRoot) {
    $PSScriptRoot = $PWD
}

# Import the UIAutomation framework
Import-Module $PSScriptRoot\UIAutomation
# Hides the highlighter (this is just annoying most of the time, but can be
#  pretty useful when you're trying to troubleshoot where an action is occurring.)
[UIAutomation.Preferences]::Highlight = $false

# Start the demo application
Start-Process $PSScriptRoot\BlogDemoApp.exe

# Get the main window for our application
$MainWindow = Get-UiaWindow -Name "MainWindow" -Win32

# Start with obtaining the OutputText textbox
$OutputTextbox = $MainWindow | Get-UiaTextBox -Name "OutputText"
"OutputText's value is $($OutputTextbox.Value)"

# Click the cat button, and see what it changes the text to
$CatButton = $MainWindow | Get-UiaButton -Name "CatButton"
$null = $CatButton | Wait-UiaButtonIsEnabled -Timeout 5000 -PassThru | Invoke-UiaButtonClick
"OutputText's updated value is $($OutputTextbox.Value)"

# Verify that we can get and interact with menu items
$FileMenuItem = $MainWindow | Get-UiaMenuItem -Name "File"
$null = $FileMenuItem | Invoke-UiaMenuItemExpand

"File menu item's expandCollapseState is... $($FileMenuItem.ExpandCollapseState)"
if ($FileMenuItem.ExpandCollapseState -eq "expanded") {
    $OpenMenuItem = $MainWindow | Get-UiaMenuItem -Name "Open"
    $null = $OpenMenuItem | Invoke-UiaMenuItemSelectItem
} else {
    "Unable to expand menu item, skipping"
}

# Who likes Corgis?  Oh, that's right...
# Make sure we're on the GridViewTab
$GridViewTab = $MainWindow | Get-UiaTabItem -Name "GridViewTab"
$null = $GridViewTab | Invoke-UiaTabItemSelectItem

# Select the data cell that Kris is in
$null = $MainWindow | Get-UiaCustom -Name "Kris" | Invoke-UiaCustomSelectItem

# Switch to the tree view tab
$TreeViewTab = $MainWindow | Get-UiaTabItem -Name "TreeViewTab"
$null = $TreeViewTab | Invoke-UiaTabItemSelectItem

# Get the TreeViewItem and expand it
$TreeViewRoot = $MainWindow | Get-UiaTreeItem -Name "Menu"
$null = $TreeViewRoot | Invoke-UiaTreeItemExpand

# Verify that we can get the first child tree view item
if ($TreeViewRoot.ExpandCollapseState -eq "expanded") {
    $ChildTreeItem = $TreeViewRoot | Get-UiaTreeItem -Name "Child Item 2"
    "Child item is offscreen: $($ChildTreeItem.Current.IsOffscreen)"
} else {
    "Unable to expand parent item, so skipping search for child item"
}

# Verify that we can add a new tree view item, and it appears
$AddTreeItemTextBox = $MainWindow | Get-UiaEdit -Name "TreeViewInputTextBox"
$AddTreeItemButton = $MainWindow | Get-UiaButton -Name "AddItemButton"
$null = $AddTreeItemTextBox | Set-UiaEditText -Text "NewItem"
# We're gonna use an explicit wait here, just to show that you can.  This button is never actually disabled
$null = $AddTreeItemButton | Wait-UiaButtonIsEnabled -Timeout 5000 -PassThru | Invoke-UiaButtonClick

try {
    $NewItem = $MainWindow | Get-UiaTreeItem -Name "NewItem"
} catch {
    "Unable to find NewItem"
}

if (-not $NewItem) {
    # let's see if switching tabs and then switching back refreshes the context
    $null = $GridViewTab | Invoke-UiaTabItemSelectItem
    $null = $TreeViewTab | Invoke-UiaTabItemSelectItem

    try {
        $NewItem = $MainWindow | Get-UiaTreeItem -Name "NewItem"
    } catch {
        "Still unable to find NewItem"
        throw
    }
}

if ($NewItem) {
    "Our new TreeItem appeared in the list!"
}

$null = $MainWindow | Get-UiaButton -Name "Close" | Invoke-UiaButtonClick