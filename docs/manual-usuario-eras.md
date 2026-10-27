# Manual de usuario de ERAS

Versión para los roles **ERAS Student Services Officer** y **ERAS Professional**.

> **Cómo leer este manual**
>
> - Los nombres de botones, menús y campos están **en negrita y en inglés**, tal como aparecen en pantalla.
> - Donde dice **[NEEDS CONFIRMATION]**, el dato todavía no está confirmado. No se ha inventado.
> - Los ejemplos usan personas y datos ficticios.

---

## 1. Introducción

ERAS es una aplicación web que guarda los datos de los estudiantes. Con esos datos, ERAS muestra qué estudiantes tienen más **riesgo** (es decir, más probabilidad de tener dificultades académicas o personales). También sirve para registrar evaluaciones y las ayudas que se dan después. Está pensada para el personal de servicios estudiantiles (**ERAS Student Services Officer**) y para los profesionales de apoyo (**ERAS Professional**). Con ERAS puedes ver el nivel de riesgo, registrar valoraciones y seguir las intervenciones de cada estudiante.

### ¿Qué puedo hacer según mi rol?

| Sección del menú | Student Services Officer | Professional |
|---|---|---|
| **Home** | Sí | Sí |
| **Students** | Sí | No |
| **Evaluation Processes** | Sí | No |
| **Reports** | Sí | No |
| **Assessments** (incluye **Interventions**) | Sí, puede crear, editar y borrar | Sí, pero solo puede consultar [NEEDS CONFIRMATION: si puede crear **Interventions**] |
| **Platform Settings** (menú de usuario) | Sí | No |
| **Account and Information** (menú de usuario) | Sí | Sí |

> Si no ves una sección del menú, es porque tu rol no tiene permiso para usarla. No es un error.

---

## 2. Getting Started (Primeros pasos)

### 2.1 Crear una cuenta

ERAS es una aplicación para las personas que trabajan en la empresa. **No necesitas crear una cuenta nueva en ERAS.** Ya tienes una cuenta de trabajo, con tu correo de la empresa.

ERAS se conecta a un **IAM**. Un IAM es el sistema de la empresa que guarda quién eres y qué puedes hacer. Por eso entras a ERAS con los mismos datos que usas en tu trabajo.

> **Tip:** Si no puedes entrar con tu correo de la empresa, pide ayuda. [NEEDS CONFIRMATION: a quién se pide ayuda con el acceso]

### 2.2 Iniciar sesión

1. Abre tu navegador (por ejemplo, Chrome o Edge).
2. Escribe la dirección de ERAS en la barra de direcciones: `https://eras.jala.edu/home?v2=true`.
3. Pulsa la tecla Enter.
4. Escribe tu correo de la empresa en la página de inicio de sesión.
5. Escribe tu contraseña.
6. Confirma el inicio de sesión.

[NEEDS CONFIRMATION: nombre de la pantalla de inicio de sesión, textos y botones, y pasos extra como código de verificación.]

Cuando entras, ERAS te lleva a **Home**.

### 2.3 Recorrido de la primera vez

Imagina que Laura Méndez es una nueva Student Services Officer y entra por primera vez.

1. Mira la **barra lateral** (el menú de la izquierda). Verás: **Home**, **Students**, **Evaluation Processes**, **Reports** y **Assessments**.
2. Mira la parte de arriba. Verás el título de la pantalla, tu nombre, tu rol y un icono de campana.
3. Haz clic en el icono de tu avatar (la figura de persona) arriba a la derecha.
4. Lee tu nombre y tu rol en el menú que se abre.
5. Haz clic en **Account and Information** para revisar tus datos.
6. Haz clic en **Home** en la barra lateral para volver al inicio.

**Home** muestra:

- **Overview**: tres cuadros con **Number of Students**, **Polls Answered** y **Evaluations**. Cada cuadro compara el periodo actual de 6 meses con el anterior.
- **Last Updated**: la fecha de la última actualización de los datos.
- **Recent Alerts**: una lista corta de alertas. Un **enlace** es un texto sobre el que se hace clic para ir a otra pantalla. El enlace **View All** abre la lista completa.
- **Connected Services**: los servicios externos conectados a ERAS. Son los mismos de **Platform Settings**, pero aquí solo puedes verlos (no cambiarlos).

> **Tip:** Para salir, haz clic en tu avatar y luego en **Log out**. Hazlo siempre que uses un computador compartido.

---

## 3. Core Features (Funciones principales)

### 3.1 Home: resumen y alertas recientes

**Para qué sirve:** ver de un vistazo los números generales y las alertas más recientes.

1. Haz clic en **Home** en la barra lateral.
2. Mira los cuadros de **Overview**.
3. Pasa el cursor por un cuadro para leer su explicación.
4. Mira la tabla **Recent Alerts**.
5. Haz clic en **View All** para ver todas las alertas.

La tabla de alertas tiene estas columnas: **Student Id**, **Student name**, **Risk Level**, **Category**, **Date** y **Status**.

**Ejemplo:** Laura ve que **Polls Answered** subió respecto al periodo anterior. Después ve en **Recent Alerts** a "Carlos Rojas", con **Risk Level** alto. Hace clic en **View All** para ver si hay más alertas parecidas.

---

### 3.2 Students: gestionar estudiantes

**Para qué sirve:** ver la lista de estudiantes, agregar uno nuevo, importar muchos a la vez y exportar la lista.

#### Agregar un estudiante a mano

1. Haz clic en **Students** en la barra lateral.
2. Haz clic en **New Student**.
3. Escribe los datos en la sección **Personal Information**: **First Name**, **Middle Name**, **Last Name**, **Date of Birth**, **Gender**, **Nationality/Citizenship**, **Country of Birth** e **ID/Passport Number**.
4. Escribe los datos en la sección **Contact Information**: **Primary Email**, **Secondary Email (Optional)**, **Mobile No.**, **Country**, **State/Province**, **City**, **Street** y **Postal Code**.
5. Escribe los datos en la sección **Academic Information**: **Cohort**, **Level of study**, **Faculty/School**, **Study modality** y **Previous Institution**.
6. Haz clic en **Save**.

Los campos obligatorios son: **First Name**, **Last Name**, **ID/Passport Number**, **Cohort** y **Primary Email**. El botón **Save** solo se activa cuando el formulario es válido.

**Ejemplo:** Laura registra a Ana Torres. Escribe **First Name** "Ana", **Last Name** "Torres", **Primary Email** "ana.torres@ejemplo.com" y **Level of study** "Bachelor". Luego hace clic en **Save**.

#### Importar estudiantes desde un archivo CSV

Un **CSV** es un archivo de texto con una tabla, donde las columnas se separan con comas. Se puede crear con Excel y guardar como CSV.

1. Haz clic en **Students** en la barra lateral.
2. Haz clic en **Import**.
3. Haz clic en el enlace de la plantilla de ejemplo (**example template**) para descargarla, si no tienes un archivo preparado.
4. Rellena la plantilla con tus estudiantes.
5. Arrastra tu archivo CSV a la ventana, o haz clic en **Browse** y elígelo.
6. Haz clic en **Next**.
7. Revisa la tabla de vista previa (**Import Students**).
8. Haz clic en **Import** para guardar. El botón muestra cuántas filas se importarán, por ejemplo **Import (25)**.

Columnas obligatorias del archivo: **Id**, **Name**, **Email** y **SIS Id**. El **SIS Id** es el identificador del estudiante que debe darte la universidad. Columnas opcionales: **Enrolled**, **Graded**, **Timely sub.**, **Avg. score**, **Below avg.**, **Raw diff.**, **Std. diff.** y **Days since access**.

> **Warning:** Las filas con errores se desmarcan solas y **no se importan**. Pasa el cursor sobre el icono de error de la fila para ver qué falla. Corrige el archivo y vuelve a importarlo.

> **Tip:** Si te equivocas de archivo, haz clic en **Back** en la vista previa para elegir otro.

**Ejemplo:** Laura tiene un archivo `estudiantes_marzo.csv` con 30 estudiantes. En la vista previa ve que 2 filas tienen el correo mal escrito. El botón dice **Import (28)**. Importa esos 28 y corrige las otras 2 después.

#### Ver o editar el perfil de un estudiante

1. Haz clic en **Students** en la barra lateral.
2. Busca al estudiante en la lista. Las columnas son **Name**, **Email**, **Timely Submissions**, **Avg. Score** y **Last Access**.
3. Haz clic en el icono de persona (**View profile**) de su fila.
4. Haz clic en **Edit**.
5. Cambia los datos que necesites.
6. Haz clic en **Save**.

> En los estudiantes que llegaron por importación, **First Name**, **Middle Name**, **Last Name** y **Primary Email** están bloqueados y no se pueden cambiar.

El icono del ojo (**See more details**) abre más detalles del estudiante. [NEEDS CONFIRMATION: qué muestra esa pantalla]

#### Exportar la lista

1. Haz clic en **Students** en la barra lateral.
2. Haz clic en **Export**.
3. Elige **To CSV** o **To PDF**.

**Export** solo aparece cuando hay estudiantes en la lista.

#### Borrar un estudiante

1. Haz clic en **Students** en la barra lateral.
2. Haz clic en el icono de papelera (**Delete student**) de la fila del estudiante.
3. Lee el mensaje de confirmación.
4. Confirma el borrado. [NEEDS CONFIRMATION: texto exacto del botón de confirmación]

> **Warning:** El estudiante se quita de la lista. Antes de borrar, comprueba que el nombre es el correcto. El icono de papelera solo aparece en estudiantes que tienen perfil y que no llegaron por importación.

---

### 3.3 Evaluation Processes: crear procesos de evaluación

**Para qué sirve:** crear un **proceso de evaluación** (un periodo en el que se aplica una encuesta a los estudiantes) y traer las respuestas, junto con los estudiantes que las dieron.

> **Antes de empezar:** necesitas una **configuración** de Cosmic Latte. Es la conexión con el servicio de encuestas. Se crea en **Platform Settings** (ver sección 4 de este manual).

#### Crear un proceso de evaluación

1. Haz clic en **Evaluation Processes** en la barra lateral.
2. Haz clic en **Add new**. Si la lista está vacía, haz clic en **Let's create a new one!**.
3. Escribe el nombre en **Enter a name**.
4. Selecciona el país en el selector de país.
5. Selecciona una opción en **Select a Configuration**.
6. Selecciona la encuesta en **Select a COSMIC LATTE poll by name**. Si todavía no la conoces, elige **-- I prefer to choose later --**.
7. Elige las fechas de inicio y fin en **Choose a date range**.
8. Haz clic en **Create**.

**Ejemplo:** Laura crea "Encuesta de bienestar 2026-1". Elige el país "Colombia", la configuración "CosmicUni", la encuesta "Bienestar estudiantil" y las fechas del 1 de marzo al 30 de abril.

La lista muestra: **Id**, **Name**, **Country**, **Poll Name**, **Period** y **Status**. El estado puede ser:

| Status | Significado |
|---|---|
| **Pending** | Aún no se han importado las respuestas. |
| **Ready** | La evaluación aún no terminó. La encuesta puede haberse usado en otras evaluaciones. |
| **In Progress** | Ya se importó y sigue en curso. |
| **Completed** | Ya se importó y terminó. |
| **Uncompleted** | No se completó antes de la fecha límite. |
| **New** | El proceso no tiene un estado definido. |

#### Importar las respuestas de los estudiantes

1. Haz clic en **Evaluation Processes** en la barra lateral.
2. Busca tu proceso en la lista.
3. Haz clic en **New Import** en la fila del proceso.
4. Selecciona una opción en **Select a configuration to start**.
5. Selecciona la encuesta en **Select a survey from Cosmic Latte**.
6. Elige las fechas en **Enter a date range**.
7. Haz clic en **Import Answers**.
8. Espera en la pantalla **Import Progress**. Muestra una barra de avance.
9. Revisa la tabla, con **Name**, **Email**, **Cohort** y **Status**.
10. Marca las filas que quieres guardar.
11. Haz clic en **Import selected**. El botón muestra cuántas hay, por ejemplo **Import selected (40)**.

> **Warning:** **New Import** está desactivado si el proceso no tiene una encuesta elegida. También se oculta si el estado es incompleto o no iniciado. Elige la encuesta primero, editando el proceso.

> **Tip:** Si alguna fila falla, márcala y haz clic en **Retry selected**. Haz clic en **Back** para salir de la pantalla.

**Ejemplo:** Laura abre "Encuesta de bienestar 2026-1" y hace clic en **New Import**. Elige las fechas del 1 al 30 de abril. En la tabla aparecen 120 estudiantes. Marca todos y hace clic en **Import selected (120)**.

#### Ver una importación anterior

1. Haz clic en **Evaluation Processes** en la barra lateral.
2. Haz clic en **View Import** en la fila del proceso.

#### Editar o borrar un proceso

1. Haz clic en **Evaluation Processes** en la barra lateral.
2. Haz clic en **Edit evaluation** en la fila del proceso.
3. Cambia los datos que necesites.
4. Haz clic en el botón de guardar, o en **Delete** para borrar el proceso. [NEEDS CONFIRMATION: texto del botón de guardar al editar]

> **Warning:** ERAS pregunta si estás seguro antes de borrar un proceso. **Un proceso borrado no se puede recuperar.**

---

### 3.4 Reports: niveles de riesgo de evaluaciones y cohortes

**Para qué sirve:** ver en gráficos y tablas el nivel de riesgo de una evaluación y de sus cohortes. Una **cohorte** es un grupo de estudiantes que comparten algo, por ejemplo el semestre en que empezaron.

Hay tres informes:

- **Dynamic Charts**: gráficos por pregunta o variable.
- **Summary Charts**: un resumen del riesgo académico (**Global Academic Risk**) y una tabla **Student Answers**.
- **Polls Answered**: la lista de encuestas respondidas.

#### Ver el resumen del riesgo

1. Haz clic en **Reports** en la barra lateral.
2. Haz clic en la pestaña **Summary Charts**. Puedes cambiar entre los tres informes con las pestañas de la parte de arriba.
3. Selecciona una opción en **Evaluation Process**.
4. Selecciona una o más opciones en **Cohort**.
5. Haz clic en **Apply**.
6. Mira el gráfico **Global Academic Risk**.
7. Mira la tabla **Student Answers**.

Los colores de la leyenda son:

| Color | Nivel |
|---|---|
| Gris | **No Answer** (sin respuesta) |
| Verde | **Low** (bajo) |
| Verde claro | **Low-Medium** |
| Amarillo | **Medium** (medio) |
| Naranja | **Medium-High** |
| Rojo | **High** (alto) |

Para cambiar el tipo de gráfico, haz clic en el icono de gráfico (**Toggle chart type**). Elige **Heatmap chart** (mapa de calor, con colores) o **Column chart** (columnas). Para guardar el informe, haz clic en **Export**.

**Ejemplo:** Laura elige "Encuesta de bienestar 2026-1" y la cohorte "Ingeniería 2025". Hace clic en **Apply**. Ve muchas casillas rojas (**High**) en un componente. Hace clic en esa parte del gráfico para abrir el panel con el detalle por pregunta.

#### Ver gráficos por variable

1. Haz clic en **Reports** en la barra lateral.
2. Abre **Dynamic Charts**.
3. Selecciona una opción en **Evaluation Process**.
4. Selecciona una o más opciones en **Cohort**.
5. Selecciona opciones en **Component**.
6. Selecciona opciones en **Variable**.
7. Haz clic en **Apply**.
8. Haz clic en un punto del gráfico para abrir el panel de detalles.

#### Ver las encuestas respondidas

1. Haz clic en **Reports** en la barra lateral.
2. Abre **Polls Answered**.
3. Selecciona **Evaluation Process** y **Cohort**.
4. Haz clic en **Apply**.

> **Tip:** El botón **Apply** se activa solo cuando eliges al menos una cohorte.

---

### 3.5 Assessments e Interventions

**Para qué sirve:** registrar una **valoración** (**Assessment**: una revisión que hace un profesional sobre uno o más estudiantes) y las **intervenciones** (**Interventions**: las acciones concretas de ayuda, como una tutoría).

La sección **Assessments** tiene dos pestañas: **Assessments** e **Interventions**.

#### Crear una valoración

1. Haz clic en **Assessments** en la barra lateral.
2. Abre la pestaña **Assessments**.
3. Haz clic en **Create Assessment**.
4. Selecciona uno o más estudiantes en **Students**.
5. Elige la fecha en **Date**.
6. Selecciona quién la envía en **Submitter**.
7. Selecciona el tipo de servicio en **Service**.
8. Selecciona el responsable en **Professional**.
9. Escribe una nota en **Professional comment**.
10. Haz clic en **Create**.

**Ejemplo:** Laura crea una valoración para Ana Torres y Carlos Rojas. Elige **Service** "Tutoring" y **Professional** "Dr. Pérez". En **Professional comment** escribe "Faltan entregas en matemáticas".

La tabla muestra: **Date**, **Submitter**, **Service**, **Professional**, **Student**, **Status**, **Comment** y **Actions**. El estado puede ser **Remitted**, **In Progress** o **Finalized**. Una valoración nueva nace con el estado **Remitted**, que aquí significa "creada".

#### Ver, editar o borrar una valoración

1. Haz clic en **Assessments** en la barra lateral.
2. Haz clic en el icono del ojo (**View**) para leer los detalles en el panel **Assessment Details**.
3. Haz clic en el icono del lápiz (**Edit**) para editarla.
4. Cambia los datos que necesites.
5. Haz clic en **Edit** para guardar. [NEEDS CONFIRMATION: en qué orden se cambia el estado]
6. Haz clic en el icono de papelera (**Delete**) para borrarla.

> **Warning:** Una valoración en estado **Finalized** ya no se puede editar. Además, no se pueden crear ni borrar intervenciones de una valoración finalizada. Finaliza solo cuando el trabajo esté terminado.

> **Warning:** Si cierras una ventana con cambios sin guardar, puedes perderlos. Haz clic en **Create** o en **Edit** antes de cerrar.

#### Crear una intervención

1. Haz clic en **Assessments** en la barra lateral.
2. Abre la pestaña **Assessments**.
3. Haz clic en el ojo (**View**) de la valoración.
4. Haz clic en **Create Intervention** en el panel **Assessment Details**.
5. Elige la fecha en **Date**.
6. Selecciona **Individual** o **Group** en **Intervention Type**.
7. Selecciona **Tutoring**, **Counseling**, **Workshop** o **Mentoring** en **Activity**.
8. Selecciona **Academic**, **Social**, **Emotional** o **Vocational** en **Area**.
9. Selecciona **In place** o **Remote** en **Mode**.
10. Selecciona al estudiante (o a los estudiantes) en **Student** o **Student (s)**.
11. Selecciona **Low**, **Medium** o **High** en **Risk Level**.
12. Adjunta los documentos en **Attached Document (s)**.
13. Haz clic en **Create**.

También puedes entrar por la pestaña **Interventions**, elegir una valoración en el filtro **Assessment** de arriba y hacer clic en **Create Intervention**.

Los adjuntos pueden ser PDF, JPG, PNG o TXT. Se permiten hasta 5 archivos, de máximo 10 MB cada uno.

**Ejemplo:** Laura crea una intervención para Ana Torres. Elige **Intervention Type** "Individual", **Activity** "Tutoring", **Area** "Academic", **Mode** "In place" y **Risk Level** "High". Adjunta `acta_tutoria.pdf` y hace clic en **Create**.

#### Ver, editar o borrar una intervención

1. Haz clic en **Assessments** en la barra lateral.
2. Abre la pestaña **Interventions**.
3. Elige la valoración en el filtro **Assessment** de arriba.
4. Haz clic en el ojo (**View**) para ver el panel **Intervention Details**.
5. Haz clic en el lápiz (**Edit**) para editar. Puedes cambiar el **Attendance** (quién asistió).
6. Haz clic en **Save**.
7. Haz clic en la papelera (**Delete**) para borrarla.

Para guardar la lista en un archivo, haz clic en el icono **Export CSV**.

> **Warning:** Borrar una intervención quita su registro. Revisa bien cuál eliges.

---

### 3.6 Recent Alerts: lista completa de alertas

**Para qué sirve:** ver todas las alertas, no solo las más recientes.

1. Haz clic en **Home** en la barra lateral.
2. Haz clic en **View All**, junto a **Recent Alerts**.
3. Pasa de página con los controles de la tabla.

**Ejemplo:** Laura quiere ver las alertas de la semana pasada. Entra en **View All** y busca las fechas de la columna **Date**.

---

## 4. Settings and Preferences (Configuración)

ERAS no tiene una pantalla general llamada "Settings". Estas son las opciones que existen:

| Dónde está | Qué cambia | Quién la ve |
|---|---|---|
| Menú de usuario > **Account and Information** | Ver tus datos (**Employee ID**, **Position**, **Department**, **Phone**, **Role**, **About**) y editarlos con **Edit**. | Todos |
| Menú de usuario > **Platform Settings** | Abre la pantalla de **Cosmic Latte**. Ahí se administran las conexiones con el servicio de encuestas. | Student Services Officer |
| Menú de usuario > **Log out** | Cierra tu sesión. | Todos |

> El **menú de usuario** se abre al hacer clic en tu avatar, arriba a la derecha.

### 4.1 Account and Information

1. Haz clic en tu avatar.
2. Haz clic en **Account and Information**.
3. Haz clic en **Edit**.
4. Cambia los datos que necesites.
5. Haz clic en **Save**. Para no guardar, haz clic en **Cancel**.

Puedes editar **Employee ID**, **Position**, **Department**, **Phone** y **About** (información tuya).
### 4.2 Platform Settings > Cosmic Latte

**Para qué sirve:** guardar la conexión con **Cosmic Latte**, el servicio externo de encuestas. Sin esta conexión no puedes crear procesos de evaluación ni importar respuestas. Una **API Key** es una clave secreta que le da permiso a ERAS para pedir datos a ese servicio.

#### Crear una configuración

1. Haz clic en tu avatar.
2. Haz clic en **Platform Settings**.
3. Haz clic en el botón **+** (**Add new configuration**), junto a **Configurations**.
4. Escribe un nombre en **Configuration Name**. Debe tener entre 3 y 20 caracteres y ser único.
5. Escribe la dirección del servicio en **Base URL**. [NEEDS CONFIRMATION: de dónde se obtiene esta dirección]
6. Escribe la clave en **API Key**. Debe tener exactamente 32 caracteres.
7. Selecciona **Cosmic Latte** en **Service Provider**.
8. Haz clic en **Save Configuration**.

> **Warning:** La **API Key** es como una contraseña. No la compartas ni la envíes por correo.

**Ejemplo:** Laura escribe **Configuration Name** "CosmicUni", la **Base URL** que le dieron y la **API Key** de 32 caracteres. Elige **Service Provider** "Cosmic Latte" y hace clic en **Save Configuration**.

#### Probar, editar o borrar una configuración

1. Haz clic en tu avatar.
2. Haz clic en **Platform Settings**.
3. Busca la tarjeta de tu configuración.
4. Haz clic en **Test Connection** para comprobar que funciona. Una marca verde significa que funciona. Una cruz significa que falla. También se muestra la fecha de la última prueba (**last test**).
5. Haz clic en **Edit Configuration** para cambiar datos.
6. Haz clic en **Delete Configuration** para borrarla.

> **Warning:** Si borras una configuración, **no podrás crear más procesos de evaluación ni importar respuestas** con ella. Borra una configuración solo si estás seguro.

---

## 5. Common Tasks (Tareas comunes)

### 5.1 Agregar un estudiante

1. Haz clic en **Students**.
2. Haz clic en **New Student**.
3. Rellena el formulario.
4. Haz clic en **Save**.

### 5.2 Importar estudiantes con un archivo CSV

1. Haz clic en **Students**.
2. Haz clic en **Import**.
3. Haz clic en **Browse** y elige tu archivo.
4. Haz clic en **Next**.
5. Revisa las filas con errores.
6. Haz clic en **Import**.

### 5.3 Crear un proceso de evaluación e importar las respuestas

1. Configura Cosmic Latte en **Platform Settings** (una sola vez).
2. Haz clic en **Evaluation Processes**.
3. Haz clic en **Add new**.
4. Rellena el formulario y guárdalo.
5. Haz clic en **New Import** en la fila del proceso.
6. Haz clic en **Import Answers**.
7. Haz clic en **Import selected**.

### 5.4 Ver los niveles de riesgo

1. Haz clic en **Reports**.
2. Abre **Summary Charts**.
3. Elige **Evaluation Process** y **Cohort**.
4. Haz clic en **Apply**.

### 5.5 Registrar una valoración con su intervención

1. Haz clic en **Assessments**.
2. Haz clic en **Create Assessment** y guárdala con **Create**.
3. Haz clic en el ojo (**View**) de la valoración.
4. Haz clic en **Create Intervention**.
5. Rellena el formulario.
6. Haz clic en **Create**.

### 5.6 Revisar las alertas

1. Haz clic en **Home**.
2. Mira **Recent Alerts**.
3. Haz clic en **View All** para ver la lista completa.

---

## 6. Troubleshooting (Solución de problemas)

### No veo una sección del menú

- **Qué ves:** faltan opciones como **Students** o **Reports**.
- **Causa probable:** tu rol no tiene permiso para esa sección. El rol **ERAS Professional** solo ve **Home** y **Assessments**.
- **Solución:**
  1. Haz clic en tu avatar.
  2. Lee tu rol bajo tu nombre.
  3. Si crees que tu rol es incorrecto, avisa a tu administrador.

### Los botones **Create Assessment**, **Edit** o **Delete** están grises

- **Qué ves:** los botones no responden.
- **Causa probable:** tu rol solo puede consultar, o la valoración ya está en estado **Finalized**.
- **Solución:**
  1. Revisa tu rol en el menú de usuario.
  2. Revisa la columna **Status** de la valoración.
  3. Si necesitas cambiarla, consulta a un Student Services Officer.

### Al crear un proceso de evaluación aparece "No configurations found"

- **Qué ves:** el mensaje "No configurations found. You need to create a configuration before you can start an evaluation."
- **Causa probable:** aún no existe una conexión con Cosmic Latte.
- **Solución:**
  1. Haz clic en tu avatar.
  2. Haz clic en **Platform Settings**.
  3. Crea una configuración (ver sección 4.2).
  4. Vuelve a **Evaluation Processes** e inténtalo de nuevo.

### Al importar respuestas aparece "No polls found. Invalid or expired API key"

- **Qué ves:** la lista de encuestas está vacía y se muestra ese aviso.
- **Causa probable:** la **API Key** es incorrecta o venció.
- **Solución:**
  1. Haz clic en el enlace **Configuration** del aviso.
  2. Haz clic en **Edit Configuration** en la tarjeta.
  3. Escribe la **API Key** correcta.
  4. Haz clic en **Save Configuration**.
  5. Haz clic en **Test Connection** para comprobarlo.

### El botón **New Import** no aparece o está gris

- **Qué ves:** no puedes importar las respuestas de un proceso.
- **Causa probable:** el proceso no tiene encuesta elegida, o su estado no permite importar.
- **Solución:**
  1. Haz clic en **Edit evaluation** en la fila del proceso.
  2. Elige una encuesta en **Select a COSMIC LATTE poll by name**.
  3. Guarda los cambios.

### Aparece "Import failed" o "Could not start the import extraction"

- **Qué ves:** un aviso de error rojo al iniciar la importación.
- **Causa probable:** Cosmic Latte no respondió o los datos elegidos no son válidos.
- **Solución:**
  1. Lee el mensaje completo del aviso.
  2. Revisa tus fechas y tu encuesta.
  3. Haz clic en **Test Connection** en **Platform Settings**.
  4. Inténtalo otra vez. Si sigue fallando, avisa a soporte. [NEEDS CONFIRMATION: contacto de soporte]

### Mi archivo CSV muestra errores en la vista previa

- **Qué ves:** avisos amarillos y filas desmarcadas.
- **Causa probable:** faltan columnas obligatorias o hay datos mal escritos, como un correo inválido.
- **Solución:**
  1. Lee los avisos de arriba de la tabla.
  2. Pasa el cursor sobre el icono de error de cada fila.
  3. Haz clic en **Back**.
  4. Corrige el archivo en Excel y guárdalo como CSV.
  5. Vuelve a elegirlo con **Browse**.

### Los informes dicen "Please select the required fields" o "No data found"

- **Qué ves:** no aparecen gráficos.
- **Causa probable:** faltan filtros, o no hay datos para esos filtros.
- **Solución:**
  1. Elige **Evaluation Process**.
  2. Elige al menos una opción en **Cohort**.
  3. Haz clic en **Apply**.
  4. Si dice "No data found", prueba con otra cohorte u otro proceso.

### Aparece "There was an error looking for evaluation processes"

- **Qué ves:** ese mensaje en los filtros de **Reports**.
- **Causa probable:** ERAS no pudo cargar la lista de procesos.
- **Solución:**
  1. Recarga la página con la tecla F5.
  2. Si sigue, avisa a soporte. [NEEDS CONFIRMATION: contacto de soporte]

### No puedo subir un documento a una intervención

- **Qué ves:** el archivo no se acepta.
- **Causa probable:** el tipo o el tamaño no está permitido.
- **Solución:**
  1. Comprueba que el archivo es PDF, JPG, PNG o TXT.
  2. Comprueba que pesa menos de 10 MB.
  3. Comprueba que no pasas de 5 archivos.

### No veo el icono de papelera en un estudiante

- **Qué ves:** la fila no tiene la acción **Delete student**.
- **Causa probable:** el estudiante llegó por importación o no tiene perfil.
- **Solución:** no se puede borrar desde esta pantalla. [NEEDS CONFIRMATION: cómo se retira un estudiante importado]

### Aparece "We couldn't load the profile information"

- **Qué ves:** tu perfil no se carga en **Account and Information**.
- **Causa probable:** un fallo temporal de conexión.
- **Solución:**
  1. Recarga la página con F5.
  2. Vuelve a abrir **Account and Information**.
  3. Si sigue, avisa a soporte.

### No puedo iniciar sesión

- **Qué ves:** la página de inicio de sesión rechaza tus datos.
- **Causa probable:** [NEEDS CONFIRMATION]
- **Solución:** [NEEDS CONFIRMATION]

---

## 7. Glossary (Glosario)

| Término | Significado |
|---|---|
| **Alert / Recent Alerts** | Aviso sobre un estudiante con riesgo. Se ve en **Home**. |
| **API Key** | Clave secreta que permite a ERAS conectarse con Cosmic Latte. |
| **Assessment** | Valoración: una revisión que hace un profesional sobre uno o más estudiantes. |
| **Attendance** | Quién asistió a una intervención. |
| **Avatar** | Icono de persona, arriba a la derecha. Abre el menú de usuario. |
| **Barra lateral** | Menú de la izquierda con las secciones de ERAS. |
| **Base URL** | Dirección web del servicio al que se conecta ERAS. |
| **Cohort** | Cohorte: grupo de estudiantes que comparten algo, como el semestre de ingreso. |
| **Configuration** | Conexión guardada con Cosmic Latte (nombre, dirección, clave y proveedor). |
| **Cosmic Latte** | Servicio externo de encuestas del que ERAS toma las respuestas. |
| **CSV** | Archivo de texto con una tabla. Las columnas se separan con comas. |
| **Enlace** | Texto sobre el que haces clic para ir a otra pantalla. |
| **Evaluation Process** | Proceso de evaluación: un periodo en el que se aplica una encuesta a los estudiantes. |
| **Export** | Guardar una lista o informe en un archivo (CSV o PDF). |
| **Finalized** | Estado de una valoración o intervención terminada. Ya no se puede editar. |
| **Heatmap chart** | Gráfico de colores. Cada color indica un nivel de riesgo. |
| **Import** | Traer datos desde un archivo o servicio. |
| **Intervention** | Acción de ayuda a un estudiante, como una tutoría. |
| **Modal / ventana** | Cuadro que se abre encima de la pantalla y pide datos. |
| **Poll** | Encuesta que responden los estudiantes. |
| **Preview / vista previa** | Pantalla que muestra los datos antes de guardarlos. |
| **Professional** | Rol de ERAS con acceso limitado: **Home** y **Assessments**. |
| **Remitted** | Estado de una valoración recién creada. Significa "creada". |
| **Risk Level** | Nivel de riesgo: **Low**, **Low-Medium**, **Medium**, **Medium-High** o **High**. |
| **SIS Id** | Identificador del estudiante que debe dar la universidad. |
| **IAM** | Sistema de la empresa que guarda quién eres y qué puedes hacer. ERAS se conecta a él para iniciar sesión. |
| **Status** | Estado actual de un elemento (proceso, valoración, intervención o alerta). |
| **Student Services Officer** | Rol de ERAS con acceso a todas las secciones. |
| **Test Connection** | Botón que comprueba si una configuración de Cosmic Latte funciona. |
