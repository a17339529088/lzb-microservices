#!/bin/bash
# LDAP 初始化脚本 - 在 OpenLDAP 容器启动后执行

echo "等待 OpenLDAP 启动..."
sleep 10

echo "添加 LDAP 数据..."
docker exec lzb-openldap ldapadd -x -D "cn=admin,dc=lzb,dc=com" -w admin << 'EOF'
# 组织单元: users
dn: ou=users,dc=lzb,dc=com
objectClass: organizationalUnit
ou: users

# 组织单元: groups
dn: ou=groups,dc=lzb,dc=com
objectClass: organizationalUnit
ou: groups

# 测试用户: ldap_user_1 (USER角色)
dn: cn=ldap_user_1,ou=users,dc=lzb,dc=com
objectClass: inetOrgPerson
objectClass: organizationalPerson
objectClass: person
objectClass: top
cn: ldap_user_1
sn: User1
uid: ldap_user_1
userPassword: ldap_user_1

# 测试用户: ldap_editor_1 (EDITOR角色)
dn: cn=ldap_editor_1,ou=users,dc=lzb,dc=com
objectClass: inetOrgPerson
objectClass: organizationalPerson
objectClass: person
objectClass: top
cn: ldap_editor_1
sn: Editor1
uid: ldap_editor_1
userPassword: ldap_editor_1

# 测试用户: ldap_adm_1 (PRODUCT_ADMIN角色)
dn: cn=ldap_adm_1,ou=users,dc=lzb,dc=com
objectClass: inetOrgPerson
objectClass: organizationalPerson
objectClass: person
objectClass: top
cn: ldap_adm_1
sn: Admin1
uid: ldap_adm_1
userPassword: ldap_adm_1

# 用户组: users
dn: cn=users,ou=groups,dc=lzb,dc=com
objectClass: groupOfNames
cn: users
member: cn=ldap_user_1,ou=users,dc=lzb,dc=com

# 用户组: editors
dn: cn=editors,ou=groups,dc=lzb,dc=com
objectClass: groupOfNames
cn: editors
member: cn=ldap_editor_1,ou=users,dc=lzb,dc=com

# 用户组: admins
dn: cn=admins,ou=groups,dc=lzb,dc=com
objectClass: groupOfNames
cn: admins
member: cn=ldap_adm_1,ou=users,dc=lzb,dc=com
EOF

echo "LDAP 数据添加完成！"
