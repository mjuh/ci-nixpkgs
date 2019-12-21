{ description, action, command }:

''
  print "${description}\n";
  $dockerNode->${action}("${command}");
''
