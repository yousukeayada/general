```plantuml
interface UserDetails {
    - getAuthorities()
    - getPassword()
    - getUsername()
    - isAccountNonExpired()
    - isAccountNonLocked()
    - isCredentialsNonExpired()
    - isEnabled()
}
class User implements UserDetails {
    - username
    - password
    - enabled
    - accountNonExpired
    - credentialsNonExpired
    - accountNonLocked
    - authorities
}
note right of UserDetails
username, password, authorities のみの
コンストラクタもある
end note
class UserDetailsImpl implements UserDetails {

}


class LoginUser {
    @Entity
    - id
    - username
    - password
}

interface UserRepository extends JpaRepository {
    @Repository
    - findByUsername(username)
}

interface UserDetailsService {
    - loadUserByUsername(): UserDetails
}
class UserDetailsServiceImpl implements  UserDetailsService {
    @Service
    - loadUserByUsername()
}

class WebSecurityConfig extends WebSecurityConfigurerAdapter {
    @Configuration
    - configure(WebSecurity)
    - configure(HttpSecurity)
    - configure(AuthenticationManagerBuilder)
}
note bottom of WebSecurityConfig: コントローラのような役割

WebSecurityConfig -> UserDetailsServiceImpl
UserDetailsServiceImpl -> UserRepository: 呼び出し
UserRepository -> LoginUser: 検索
LoginUser --> UserRepository: 結果
UserRepository --> UserDetailsServiceImpl: 結果
UserDetailsServiceImpl ---> User: 返却値
```