class HostConfig{
  static const host= String.fromEnvironment(
    'HOST',
    defaultValue: '10.0.0.2'
  ) ;
}