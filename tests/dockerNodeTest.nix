{ description, action, command }:

''
  print "${description}\n";
  print $dockerNode->${action}("${command}");
''
