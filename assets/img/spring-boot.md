```plantuml
agent Controller 
agent HTML
agent Service
agent Repository
database DB

Controller -> HTML : model.addAttribute()
HTML -> Controller : th:hoge
Controller --> Service : Entity
Service --> Repository : save(), findAll()
Repository --> DB : SQL（application.propertiesに接続設定）
```