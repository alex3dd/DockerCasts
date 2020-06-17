
$POKER_HAND_COUNT = 5
$FLASH_FILE='flush.dat'
$suit = @('c','d','h','s')
$card_rank = @('T','J','Q','K', 'A')
$card_rank_num = @(10,11,12,13,14)


$poker_hand = @()

#open a file, check each card upper case first letter and lower case second letter 
try {
  # if file does not exist will fail with exception 
  $file = (Get-Content $FLASH_FILE)
  $file.trim().Split(' ')|foreach{
     try { $poker_hand += ($_[0]).ToString().ToUpper()+''+($_[1]).ToString().ToLower() } catch { throw $_.Exception.Message }
  }
} catch { throw $_.Exception.Message }

# Validate if poker_hand less then 5
if ($poker_hand.Count -lt $POKER_HAND_COUNT) { Write-Host "You have $($poker_hand.Count) cards and Poker hand should have 5 cards."; exit 0 }

# Validate if poker_hand greater then 5, then will cut cards after 5
if ($poker_hand.Count -gt $POKER_HAND_COUNT) 
{ 
   Write-Host "Poker hand $poker_hand has more cards in file, will keep only 5 cards."; 
   $temp_list=@()
   # Because of Powershell I cannot remove lines from list, therefore I will create a new temp list and then will recreate poker_hand again 
   for($i=0; $i -lt $POKER_HAND_COUNT; $i++) { $temp_list += $poker_hand[$i] } 
   $poker_hand = $temp_list
}

# Validate duplicates
for($i = 0; $i -lt $poker_hand.Count; $i++) 
{ 
   for($j = $i+1; $j -lt $poker_hand.Count; $j++){ 
      if ($poker_hand[$i] -eq $poker_hand[$j]) { Write-Host "Duplicate found, please shuffle and deal again !"; exit 0 }
   }
} 

$is_flush = $true
$previous_suit = ''

foreach($card in $poker_hand) 
{ 
   #Write-Host "Validate Card $card"
   if ($card.Length -ne 2) { Write-Host "Poker card should has 2 characters."; exit 0 } 

   # First character validation
   try {
      # convert card first char to ascii 
      $ch = [int]$card[0]
      # this if will check if first char is letter 65('A')-84('T')
      if (($ch -ge 65) -and ( $ch -le 84 )) { 
         if (! $card[0] -contains $card_rank) { Write-Host "Poker card rank character $($card[0]) should be in $card_rank range "; exit 0 }
        }
      # this if will check if first char in range 2-9
      elseif (($ch -lt (48+2)) -or ( $ch -gt (48+9))) { Write-Host "Poker card rank $card should be in range 2-9."; exit 0 } 
   }
   catch{ write-host $_.Exception.Message }

   # Second character validation
  
   if (!($suit -contains $card[1])) { Write-Host "Suit not found for card $card in $suit range "; exit 0 }
  
   #Check is the flush 
   if ($previous_suit) 
   { 
      $is_flush = $is_flush -and ($previous_suit -eq $card[1]) 
      if (! $is_flush) { Write-Host "This combination is NOT treated as FLASH ! `n Input: $poker_hand `n Output: $is_flush"; exit 0 }
   } 
  
   $previous_suit = $card[1]
}

# This part is a Flush and we need determine type of Flush 
# define new numbers list
[int32[]]$poker_hand_num = @()
# Convert to integer array
foreach($card in $poker_hand) 
{ 
   $index = $card_rank.IndexOf([string]$card[0])
   if ($index -ne -1){ $poker_hand_num += $card_rank_num[$index] }
   else { $poker_hand_num += $card[0]-48 }
} 

# Sort $poker_hand_num array
#$poker_hand_num = $($poker_hand_num|Sort-Object)

# Determie if this combination is a Royal Flush
if ([system.String]::Join(" ", $poker_hand_num) -eq [system.String]::Join(" ", $card_rank_num)) { Write-Host "This combination is a Royal Flush ! `n Input: $poker_hand `n Output: $is_flush"; exit 0}

# Determie if this combination is a Straight Flush
for($i=0; $i -lt $poker_hand_num.Count-1; $i++){
   if (($poker_hand_num[$i+1] - $poker_hand_num[$i]) -ne 1) { Write-Host "This combination is a Flush ! `n Input: $poker_hand `n Output: $false"; exit 0 }
}

Write-Host "This combination is a Straight Flush ! `n Input: $poker_hand `n Output: $is_flush" 
