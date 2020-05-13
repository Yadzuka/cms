[issues]: https://bitbucket.org/Yadzuka/cms/issues?status=new&status=open
[image]: http://eustrosoft.org/img/EustroSoft2019-12-15.svg.png
[eustrosoft]: http://eustrosoft.org/

[ ![image]][eustrosoft]
[Вопросы и предложения][issues]

1. [Преднастройка](#presetting)
2. [Настройка компонентов](#components-installation)

#Control management system

## Presetting

1. Целевая операционная система - *nix подобная.
2. Используемый сервер приложений - Apache Tomcat (c Servlet V 3.1+)
3. Используемые сторонние библиотеки:
```
    1. Diff-Match-Patch by Google (Apache 2.0 Licence)<br/>
            Исходный код: [клик](https://github.com/google/diff-match-patch)
    2. Apache Commons IO 2.6 (Apache 2.0 Licence)<br/>
            JAR файл: [клик](https://mvnrepository.com/artifact/commons-io/commons-io/2.6")
    3. Apache Commons FileUpload 1.4 (Apache 2.0 Licence)<br/>
            JAR файл: [клик](https://mvnrepository.com/artifact/commons-fileupload/commons-fileupload/1.4)
```    
## Components installation:

  * В качестве тестовой директории для работы с пользователями используется папка, расположенная по пути `/s/usersdb/`
```
    Примечание:
    В файле web.xml
    Необходимо поменять комтекстный параметр на параметр вашего имени/ника/прозвища
    и создать папку по пути /s/usersdb/CONTEXT-PARAM-NAME/
    Также необходимо создать папку .pspn по пути /s/usersdb/CONTEXT-PARAM-NAME/.pspn/
    Данная папка необходима для загрузки файлов на сервер (у каждого пользователя должна быть такая папка)
```
  * Папка для логов по пути `/home/USER-NAME/workspace/logging/CMSLoggingTests/test1.txt`
```
    Примечание:
    В файле web.xml
    изменить путь: /home/yadzuka/workspace/logging/CMSLoggingTests/test1.txt
    на путь, который указывает к вашему файлу, в который будут писаться кастомные логи приложения
```
  * Проект должен находится по пути `tomcat/webapps/cms/`, где tomcat - название директории tomcat сервера приложений.
`cms/` папка находится в проекте по пути `CMSsystem/webapps/cms/`
  * JAR архивы находятся по пути `tomcat/webapps/cms/WEB-INF/lib/`:
   * DiffPatchMatch.jar
   * Sources-1.0.jar

**Для создания архивов DiffPatchMatch.jar и Sources-1.0.jar необходимо:**
   * Скачать исходный код с GitHub по ссылке в преднастройке
   * Находясь по пути `diff-match-patch/java/src/` создать манифест 
    командой `vi manifest.mf` с двумя строками внутри:
    1. `Manifest-Version: 1.0`
    2. `Created-By: 1.6.0_19 (Sun Microsystems Inc.)`

   * А после добавить перевод строки (**ОБЯЗАТЕЛЬНО!**)
   * После создать .jar архив командой:
    `jar cvmf manifest.mf DiffPatchMatch.jar name`


   * Архив Sources-1.0.jar создать с помощью команды
    `mvn package`, находясь в дириктории
    `CMSsystem/sources/`

---
Все готово!
Осталось запустить tomcat и перейти на :`cms/index.jsp|index1.jsp`
