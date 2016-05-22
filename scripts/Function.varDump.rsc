:global varDump do={
  ## for recursion
  :global varDump
  ## performs various :put with information of $value
  ## indents output with $indent
  ## inspired by http://php.net/manual/en/function.var-dump.php but RouterOS does not allow underscores in variables and functions
  ## requires Function.escapeString.rsc with function escapeString

  ## TODO: expand and add more examples from http://forum.mikrotik.com/viewtopic.php?t=91480

  :global escapeString

  :local typeOfValue [:typeof $value]
  :if ($typeOfValue = "str") do={
    :local valueLen [:len $value]
    :put "$indent:typeof=$typeOfValue;len=$valueLen;\$value=$value"
    :local escaped [$escapeString value=$value]
    :if ($value != $escaped) do={
      :put "$indent\$value escaped='$escaped'"
    }
  } else={
    :if ($typeOfValue = "array") do={
      :local valueLen [:len $value]
      :put "$indent:typeof=$typeOfValue;len=$valueLen"
      :foreach key,element in=$value do={
         $varDump value=$key indent=("  $indent")
        :local escapedKey [$escapeString value=("$key")]
         $varDump value=$element indent=("  $indent[$escapedKey]")
      };
    } else={
      :if (($typeOfValue = "nothing") or ($typeOfValue = "nil")) do={
        :put "$indent:typeof=$typeOfValue"
      } else={
        :put "$indent:typeof=$typeOfValue;\$value=$value"
      }
    }
  }
}

## Examples:
## /import scripts/Function.varDump.rsc

## > $varDump value="12345"
## :typeof=str;len=5;$value=12345

### (yes, a value without parenthesis is considered a string)
## > $varDump value=12345
## :typeof=str;len=5;$value=12345

## > $varDump value=(12345)
## :typeof=num;$value=12345

## > $varDump
## :typeof=nothing

## > $varDump value=$fooBar
## :typeof=nothing

## > $varDump value=[$fooBar]
## :typeof=nil

##> $varDump value=({1;2;3} , 5 )
##:typeof=array;len=4
##  :typeof=num;$value=0
##  [0]:typeof=num;$value=1
##  :typeof=num;$value=1
##  [1]:typeof=num;$value=2
##  :typeof=num;$value=2
##  [2]:typeof=num;$value=3
##  :typeof=num;$value=3
##  [3]:typeof=num;$value=5

##> :local convert ({}); :set ($convert->("a\00")) ("A"); :set ($convert->("b")) ("B\01"); $varDump value=$convert;
##:typeof=array;len=2
##  :typeof=str;len=2;$value=a
##  $value escaped='a\00'
##  [a\00]:typeof=str;len=1;$value=A
##  :typeof=str;len=1;$value=b
##  [b]:typeof=str;len=2;$value=B
##  [b]$value escaped='B\01'
