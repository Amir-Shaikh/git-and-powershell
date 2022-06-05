function GitBranchName () {
   try {
      $branch = git rev-parse --abbrev-ref HEAD   #get branch name

      Write-Host "  " -BackgroundColor "yellow" -ForegroundColor "black" -Nonewline
      if ($branch -eq "HEAD") {
         # we're probably in detached HEAD state, so print the SHA
         $branch = git rev-parse --short HEAD    
         Write-Host "$branch ≡ " -BackgroundColor "yellow" -ForegroundColor "black" -Nonewline
      }
      else {
         # we're on an actual branch, so print it
         Write-Host "$branch ≡ " -BackgroundColor "yellow" -ForegroundColor "black" -Nonewline
      }
   }
   catch {
      # we'll end up here if we're in a newly initiated git repo
      Write-Host "[could not load branch!]" -ForegroundColor "red" -Nonewline
   }
}

function GitDiffStatus {
   try {
      $unstaged = git diff --shortstat                                  #get unstaged files info
      $staged = git diff --cached --stat                                #get staged files info
      $untrackedfiles = git ls-files . --exclude-standard --others      #get untracked files info
      $unpushedCommit = git log origin/master..HEAD                     #get unpushed commit log
      $untrackedfilesCount = $untrackedfiles.count
     
      #if there are uncommited changes
      if ($unstaged -or $staged -or $untrackedfilesCount) { 

         Write-Host " [ " -ForegroundColor "yellow" -Nonewline
         
         if ($unstaged) {

            #getting only count from string
            $unsatagedArray = $unstaged.split(",")
            $unsatagedArray0 = $unsatagedArray.Trim().Split(" ")
            $unstaggedFiles = $unsatagedArray0[0]
            
            Write-Host "modified: $unstaggedFiles " -ForegroundColor "red" -Nonewline
         }
        
         if ($staged) {

            if ($unstaged) {
               Write-Host "| " -ForegroundColor "yellow" -Nonewline
            }

            $satagedArray = $staged[ $staged.length - 1 ].split(",")
            $satagedArray0 = $satagedArray.Trim().Split(" ")
            $staggedFiles = $satagedArray0[0]
            Write-Host "staged: $staggedFiles " -ForegroundColor "yellow" -Nonewline
         }
        
         if ($untrackedfilesCount) {
            if ($unstaged -or $staged) {
               Write-Host "| " -ForegroundColor "yellow" -Nonewline
            }
            Write-Host "untracked: $untrackedfilesCount " -ForegroundColor "red" -Nonewline
         }
         
         Write-Host "] " -ForegroundColor "yellow" -Nonewline
      }
   }
   catch {
      Write-Host " [could not load unstaged changes] " -ForegroundColor "red" -Nonewline
   }
}

function GitCommitStatus {
   try {
      $unstaged = git diff --shortstat                                  #get unstaged files info
      $staged = git diff --cached --stat                                #get staged files info
      $untrackedfiles = git ls-files . --exclude-standard --others      #get untracked files info
      $untrackedfilesCount = $untrackedfiles.count
     
      #if there are uncommited changes
      if ($unstaged -or $staged -or $untrackedfilesCount) { 
         GitDiffStatus
      }
      else {
         Write-Host " [ " -ForegroundColor "yellow" -Nonewline
         Write-Host "commited: ✓" -ForegroundColor "green" -Nonewline
         Write-Host " ] " -ForegroundColor "yellow" -Nonewline
         GitPushStatus
      }
   }
   catch {
      Write-Host " [could not load commt status] " -ForegroundColor "red" -Nonewline
   }
}

function GitPushStatus{

   try {
      $branch = git rev-parse --abbrev-ref HEAD
      if ($branch -eq "HEAD") {

         # we're probably in detached HEAD state, so print the SHA
         $branch = git rev-parse --short HEAD    
      }

      $unpushedCommit = git log origin/$branch..HEAD

      #commited but not puhsed yet
      if ($unpushedCommit) {
         Write-Host "[ " -ForegroundColor "yellow" -Nonewline
         Write-Host "pushed: x" -ForegroundColor "red" -Nonewline
         Write-Host " ] " -ForegroundColor "yellow" -Nonewline
      }
      else
      {
         Write-Host "[ " -ForegroundColor "yellow" -Nonewline
         Write-Host "pushed: ✓" -ForegroundColor "green" -Nonewline
         Write-Host " ] " -ForegroundColor "yellow" -Nonewline
      }
   }
   catch {
      Write-Host " [could not load push status] " -ForegroundColor "red" -Nonewline
   }
}


function prompt {
   $envUser = " $env:UserName@$env:computername"   #show username and coputername
   $dr = "$( Get-Location ) "   # get full path
   $userPrompt = "$('-> #' * ($nestedPromptLevel + 1)) "
   $Date = (Get-Date).ToString(" ddd. dd MMM yyyy hh:mm tt ")

   

   Write-Host
   if (Test-Path .git) {
      Write-Host "$Date" -BackgroundColor "white" -ForegroundColor "black" -Nonewline
      Write-Host $envUser -ForegroundColor "yellow" -Nonewline  #show username and coputername
      Write-Host " " -Nonewline
      
      #get git status for repo
      GitBranchName 
      GitCommitStatus

      Write-Host
      Write-Host $dr -ForegroundColor "cyan"
      
   }
   else {
      Write-Host "$Date" -BackgroundColor "white" -ForegroundColor "black" -Nonewline
      Write-Host $envUser -ForegroundColor "yellow"  #show username and coputername
      Write-Host $dr -ForegroundColor "cyan"
   }
   
   $userPrompt
}
