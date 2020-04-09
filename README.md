<h1>Control management system</h1>

<h2>Преднастройка</h2>
<p>1. Целевая операционная система - *nix подобная.</p>
<p>2. Используемый сервер приложений - Apache Tomcat </p>
<p>3. Используемые сторонние библиотеки: </p>
    <ul>
        <li>Diff-Match-Patch by Google (Apache 2.0 Licence)<br/>
            Исходный код: <a href="https://github.com/google/diff-match-patch">клик!</a> 
        </li>
    </ul>
<h2>Настройка компонентов</h2>
<p>1. В качестве тестовой директории для работы с пользователями 
    используется папка, расположенная по пути <code>/s/usersdb/</code>
</p>
<hr/>
    <i>Примечание:</i><br/>
    В файле <code>web.xml</code>
    Необходимо поменять комтекстный параметр на параметр вашего имени/ника/прозвища
    и создать папку по пути <code>/s/usersdb/CONTEXT-PARAM-NAME/</code><br/>
    Также необходимо создать папку <code>.pspn</code> по пути <code>/s/usersdb/CONTEXT-PARAM-NAME/.pspn/</code><br/>
    Данная папка необходима для загрузки файлов на сервер (у каждого пользователя должна быть такая папка)
<hr/>
<p>2. Папка для логов по пути 
    <code>/home/USER-NAME/workspace/logging/CMSLoggingTests/test1.txt</code>
</p>
<hr/>
    <i>Примечание:</i><br/>
    В классе 
    <code>CMSsystem/sources/src/main/java/org/eustrosoft/providers/LogProvider</code>
    изменить путь: <br/>
    <code>FileOutputStream("/home/yadzuka/workspace/logging/CMSLoggingTests/test1.txt", true)</code>
    на путь, который указывает к вашему файлу, в который будут писаться кастомные логи приложения
<hr/>
<p>3. Проект должен находится по пути <code>tomcat/webapps/cms/</code>, 
где tomcat - название директории tomcat сервера приложений.
<code>cms/</code> папка находится в проекте по пути <code>CMSsystem/webapps/cms/</code>
</p>
<p>4. JAR архивы находятся по пути <code>tomcat/webapps/cms/WEB-INF/lib/</code>:</p>
<ul>
    <li>DiffPatchMatch.jar</li>
    <li>Sources-1.0.jar</li>
</ul>
<hr/>
<p>Для создания архивов DiffPatchMatch.jar и Sources-1.0.jar необходимо:</p>
<ol>
    <li>Скачать исходный код с GitHub по ссылке в преднастройке</li>
    <li>Находясь по пути <code>diff-match-patch/java/src/</code> создать манифест 
    командой <code>vi manifest.mf</code> с двумя строками внутри:<br/>
    <code>Manifest-Version: 1.0<br/>
          Created-By: 1.6.0_19 (Sun Microsystems Inc.)</code>
          <br/>
    А после добавить перевод строки (<b>ОБЯЗАТЕЛЬНО!</b>)
    После создать .jar архив командой:<br/>
    <code>jar cvmf manifest.mf DiffPatchMatch.jar name</code>
    </li>
    <li>
    Архив Sources-1.0.jar создать с помощью команды
    <code>mvn package</code>, находясь в дириктории
    <code>CMSsystem/sources/</code>
    </li>
</ol>
<p><b>Все готово!</b><br/>
Осталось запустить tomcat и перейти на <code>:cms/index.jsp|index1.jsp</code>
</p>
<hr/>
