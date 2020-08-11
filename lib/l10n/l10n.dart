// File generated with arbify_flutter.
// DO NOT MODIFY BY HAND.
// ignore_for_file: lines_longer_than_80_chars, non_constant_identifier_names
// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'messages_all.dart';

class S {
  final String localeName;

  const S(this.localeName);

  static const delegate = ArbifyLocalizationsDelegate();

  static Future<S> load(Locale locale) {
    final localeName = Intl.canonicalizedLocale(locale.toString());

    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return S(localeName);
    });
  }

  static S of(BuildContext context) => Localizations.of<S>(context, S);

  String get check_met => Intl.message(
        'Comprobando, si nos conocimos antes',
        name: 'check_met',
      );

  String get we_met => Intl.message(
        'Nos conocimos antes',
        name: 'we_met',
      );

  String get hang_on => Intl.message(
        'Agárrate fuerte',
        name: 'hang_on',
      );

  String get updating => Intl.message(
        'Actualizando',
        name: 'updating',
      );

  String get skipping => Intl.message(
        'Salto a la comba',
        name: 'skipping',
      );

  String get skills => Intl.message(
        'habilidades',
        name: 'skills',
      );

  String get interests => Intl.message(
        'intereses',
        name: 'interests',
      );

  String get email => Intl.message(
        'correo electrónico',
        name: 'email',
      );

  String get password => Intl.message(
        'contraseña',
        name: 'password',
      );

  String get login_agreement_message1 => Intl.message(
        'Al continuar, acepta SevaX',
        name: 'login_agreement_message1',
      );

  String get login_agreement_terms_link => Intl.message(
        'Términos de servicio',
        name: 'login_agreement_terms_link',
      );

  String get login_agreement_message2 => Intl.message(
        'Gestionaremos la información como se describe en nuestro',
        name: 'login_agreement_message2',
      );

  String get login_agreement_privacy_link => Intl.message(
        'Política de privacidad',
        name: 'login_agreement_privacy_link',
      );

  String get and => Intl.message(
        'y',
        name: 'and',
      );

  String get login_agreement_payment_link => Intl.message(
        'Política de pago',
        name: 'login_agreement_payment_link',
      );

  String get new_user => Intl.message(
        'Nuevo Usuario',
        name: 'new_user',
      );

  String get sign_up => Intl.message(
        'Regístrate',
        name: 'sign_up',
      );

  String get sign_in => Intl.message(
        'Registrarse',
        name: 'sign_in',
      );

  String get forgot_password => Intl.message(
        'Se te olvidó tu contraseña',
        name: 'forgot_password',
      );

  String get reset => Intl.message(
        'Reiniciar',
        name: 'reset',
      );

  String get sign_in_with_google => Intl.message(
        'Inicia sesión con Google',
        name: 'sign_in_with_google',
      );

  String get sign_in_with_apple => Intl.message(
        'Iniciar sesión con Apple',
        name: 'sign_in_with_apple',
      );

  String get or => Intl.message(
        'o',
        name: 'or',
      );

  String get check_internet => Intl.message(
        'Por favor revise su conexion a internet.',
        name: 'check_internet',
      );

  String get dismiss => Intl.message(
        'Descartar',
        name: 'dismiss',
      );

  String get enter_email => Intl.message(
        'Ingrese correo electrónico',
        name: 'enter_email',
      );

  String get your_email => Intl.message(
        'Tu correo electrónico',
        name: 'your_email',
      );

  String get reset_password => Intl.message(
        'Restablecer la contraseña',
        name: 'reset_password',
      );

  String get cancel => Intl.message(
        'Cancelar',
        name: 'cancel',
      );

  String get validation_error_invalid_email => Intl.message(
        'El correo no es válido',
        name: 'validation_error_invalid_email',
      );

  String get validation_error_invalid_password => Intl.message(
        'La contraseña debe tener 6 caracteres',
        name: 'validation_error_invalid_password',
      );

  String get change_password => Intl.message(
        'Cambia la contraseña',
        name: 'change_password',
      );

  String get enter_password => Intl.message(
        'Introducir la contraseña',
        name: 'enter_password',
      );

  String get reset_password_message => Intl.message(
        'Hemos enviado el enlace de restablecimiento a su dirección de correo electrónico.',
        name: 'reset_password_message',
      );

  String get reset_dynamic_link_message => Intl.message(
        'Por favor revise su correo electrónico para establecer su contraseña. Luego ingrese esa contraseña aquí.',
        name: 'reset_dynamic_link_message',
      );

  String get close => Intl.message(
        'Cerca',
        name: 'close',
      );

  String get loading => Intl.message(
        'Cargando',
        name: 'loading',
      );

  String get your_details => Intl.message(
        'Tus detalles',
        name: 'your_details',
      );

  String get add_photo => Intl.message(
        'Añadir foto',
        name: 'add_photo',
      );

  String get full_name => Intl.message(
        'Nombre completo',
        name: 'full_name',
      );

  String get confirm => Intl.message(
        'Confirmar',
        name: 'confirm',
      );

  String get validation_error_full_name => Intl.message(
        'El nombre no puede estar vacío',
        name: 'validation_error_full_name',
      );

  String get validation_error_password_mismatch => Intl.message(
        'Las contraseñas no coinciden',
        name: 'validation_error_password_mismatch',
      );

  String get add_photo_hint => Intl.message(
        '¿Quieres agregar una foto de perfil?',
        name: 'add_photo_hint',
      );

  String get skip_and_register => Intl.message(
        'Omitir y registrarse',
        name: 'skip_and_register',
      );

  String get creating_account => Intl.message(
        'Creando cuenta',
        name: 'creating_account',
      );

  String get update_photo => Intl.message(
        'Actualizar foto',
        name: 'update_photo',
      );

  String get validation_error_email_registered => Intl.message(
        'Este correo ya está registrado',
        name: 'validation_error_email_registered',
      );

  String get camera => Intl.message(
        'Cámara',
        name: 'camera',
      );

  String get gallery => Intl.message(
        'Galería',
        name: 'gallery',
      );

  String get check_email => Intl.message(
        'Ahora, mira tu correo.',
        name: 'check_email',
      );

  String get email_sent_to => Intl.message(
        'Enviamos un correo electrónico a',
        name: 'email_sent_to',
      );

  String get verify_account => Intl.message(
        'para verificar su cuenta',
        name: 'verify_account',
      );

  String get resend_email => Intl.message(
        'Reenviar correo',
        name: 'resend_email',
      );

  String get login_after_verification => Intl.message(
        'Inicie sesión una vez que haya verificado su correo electrónico.',
        name: 'login_after_verification',
      );

  String get verification_sent => Intl.message(
        'El mensaje de verificación ha sido enviado',
        name: 'verification_sent',
      );

  String get verification_sent_desc => Intl.message(
        'Se envió un correo electrónico de verificación a su correo electrónico registrado',
        name: 'verification_sent_desc',
      );

  String get log_in => Intl.message(
        'iniciar sesión',
        name: 'log_in',
      );

  String get thanks => Intl.message(
        '¡Gracias!',
        name: 'thanks',
      );

  String get eula_title => Intl.message(
        'Acuerdo de EULA',
        name: 'eula_title',
      );

  String get eula_delcaration => Intl.message(
        'Acepto que estoy dispuesto a cumplir con estos Términos y condiciones.',
        name: 'eula_delcaration',
      );

  String get proceed => Intl.message(
        'Continuar',
        name: 'proceed',
      );

  String get skills_description => Intl.message(
        '¿En qué habilidades eres bueno que te gustaría compartir con tu comunidad?',
        name: 'skills_description',
      );

  String get no_matching_skills => Intl.message(
        'No se encontraron habilidades coincidentes',
        name: 'no_matching_skills',
      );

  String get search => Intl.message(
        'Buscar',
        name: 'search',
      );

  String get update => Intl.message(
        'Actualizar',
        name: 'update',
      );

  String get next => Intl.message(
        'próximo',
        name: 'next',
      );

  String get skip => Intl.message(
        'Omitir',
        name: 'skip',
      );

  String get interests_description => Intl.message(
        '¿Cuáles son algunos de sus intereses y pasiones que estaría dispuesto a compartir con su comunidad?',
        name: 'interests_description',
      );

  String get no_matching_interests => Intl.message(
        'No se encontraron intereses coincidentes',
        name: 'no_matching_interests',
      );

  String get bio => Intl.message(
        'Bio',
        name: 'bio',
      );

  String get bio_description => Intl.message(
        'Cuéntenos un poco sobre usted en unas pocas frases. Por ejemplo, qué te hace único.',
        name: 'bio_description',
      );

  String get bio_hint => Intl.message(
        'Cuéntanos un poco sobre ti.',
        name: 'bio_hint',
      );

  String get validation_error_bio_empty => Intl.message(
        'Es fácil, por favor complete algunas palabras sobre usted.',
        name: 'validation_error_bio_empty',
      );

  String get validation_error_bio_min_characters => Intl.message(
        'Mínimo 50 caracteres *',
        name: 'validation_error_bio_min_characters',
      );

  String get join => Intl.message(
        'Unirse',
        name: 'join',
      );

  String get joined => Intl.message(
        'Unido',
        name: 'joined',
      );

  String get timebanks_near_you => Intl.message(
        'Bancos de tiempo cerca de ti',
        name: 'timebanks_near_you',
      );

  String get find_your_timebank => Intl.message(
        'Encuentra tu banco de tiempo',
        name: 'find_your_timebank',
      );

  String get looking_existing_timebank => Intl.message(
        'Buscando un banco de tiempo existente para unirse',
        name: 'looking_existing_timebank',
      );

  String get find_timebank_help_text => Intl.message(
        'Escribe el nombre de tu banco de tiempo. Ejemplo: Alaska (mínimo 1 carácter)',
        name: 'find_timebank_help_text',
      );

  String get no_timebanks_found => Intl.message(
        'No se encontraron bancos de tiempo',
        name: 'no_timebanks_found',
      );

  String get timebank => Intl.message(
        'Banco de tiempo',
        name: 'timebank',
      );

  String get created_by => Intl.message(
        'Creado por',
        name: 'created_by',
      );

  String get create_timebank => Intl.message(
        'Crea un banco de tiempo',
        name: 'create_timebank',
      );

  String get timebank_gps_hint => Intl.message(
        'Asegúrese de tener el GPS encendido para ver la lista de bancos de tiempo que le rodean',
        name: 'timebank_gps_hint',
      );

  String get create_timebank_confirmation => Intl.message(
        '¿Está seguro de que desea crear un nuevo banco de tiempo, en lugar de unirse a un banco de tiempo existente? La creación de un nuevo banco de tiempo implica que usted será responsable de administrar el banco de tiempo, lo que incluye agregar miembros y administrar las necesidades de los miembros, responder oportunamente a las preguntas de los miembros, lograr la resolución de conflictos y organizar comidas compartidas mensuales. Para convertirse en miembro de un banco de tiempo existente, necesitará saber el nombre del banco de tiempo y tener un código de invitación o enviar una solicitud para unirse al banco de tiempo.',
        name: 'create_timebank_confirmation',
      );

  String get try_later => Intl.message(
        'Por favor, inténtelo de nuevo más tarde',
        name: 'try_later',
      );

  String get log_out => Intl.message(
        'Cerrar sesión',
        name: 'log_out',
      );

  String get log_out_confirmation => Intl.message(
        '¿Está seguro de que desea cerrar la sesión?',
        name: 'log_out_confirmation',
      );

  String get requested => Intl.message(
        'Pedido',
        name: 'requested',
      );

  String get rejected => Intl.message(
        'Rechazado',
        name: 'rejected',
      );

  String get join_timebank_code_message => Intl.message(
        'Ingrese el código que recibió de su administrador para ver las oportunidades de voluntariado.',
        name: 'join_timebank_code_message',
      );

  String get join_timebank_request_invite_hint => Intl.message(
        'Si no tiene un código, haga clic en',
        name: 'join_timebank_request_invite_hint',
      );

  String get join_timebank_request_invite => Intl.message(
        'Solicitud de invitación',
        name: 'join_timebank_request_invite',
      );

  String get join_timbank_already_requested => Intl.message(
        'Ya lo solicitaste a este Timebank. Espere hasta que se acepte la solicitud',
        name: 'join_timbank_already_requested',
      );

  String get join_timebank_question => Intl.message(
        '¿Por qué quieres unirte al',
        name: 'join_timebank_question',
      );

  String get reason => Intl.message(
        'Razón',
        name: 'reason',
      );

  String get validation_error_general_text => Intl.message(
        'Por favor ingrese un texto',
        name: 'validation_error_general_text',
      );

  String get send_request => Intl.message(
        'Enviar petición',
        name: 'send_request',
      );

  String get code_not_found => Intl.message(
        'Código no encontrado',
        name: 'code_not_found',
      );

  String get validation_error_wrong_timebank_code => Intl.message(
        'El código no se registró, verifique el código e inténtelo de nuevo.',
        name: 'validation_error_wrong_timebank_code',
      );

  String get validation_error_join_code_expired => Intl.message(
        '¡Código caducado!',
        name: 'validation_error_join_code_expired',
      );

  String get join_code_expired_hint => Intl.message(
        'El código ha caducado, solicite al administrador uno nuevo.',
        name: 'join_code_expired_hint',
      );

  String get awesome => Intl.message(
        '¡Increíble!',
        name: 'awesome',
      );

  String get timebank_onboarding_message => Intl.message(
        'Te han incorporado a',
        name: 'timebank_onboarding_message',
      );

  String get successfully => Intl.message(
        'Exitosamente',
        name: 'successfully',
      );

  String get validation_error_timebank_join_code_redeemed => Intl.message(
        'Código de banco de tiempo ya canjeado',
        name: 'validation_error_timebank_join_code_redeemed',
      );

  String get validation_error_timebank_join_code_redeemed_self => Intl.message(
        'El código del banco de tiempo que ha proporcionado ya ha sido canjeado anteriormente por usted. Solicite al administrador de Timebank un nuevo código.',
        name: 'validation_error_timebank_join_code_redeemed_self',
      );

  String get code_expired => Intl.message(
        '¡Código caducado!',
        name: 'code_expired',
      );

  String get enter_code_to_verify => Intl.message(
        'Ingrese el PIN para verificar',
        name: 'enter_code_to_verify',
      );

  String get creating_join_request => Intl.message(
        'Crear solicitud de unión',
        name: 'creating_join_request',
      );

  String get feeds => Intl.message(
        'Feeds',
        name: 'feeds',
      );

  String get projects => Intl.message(
        'Proyectos',
        name: 'projects',
      );

  String get offers => Intl.message(
        'Ofertas',
        name: 'offers',
      );

  String get requests => Intl.message(
        'Peticiones',
        name: 'requests',
      );

  String get about => Intl.message(
        'Acerca de',
        name: 'about',
      );

  String get members => Intl.message(
        'Miembros',
        name: 'members',
      );

  String get manage => Intl.message(
        'Gestionar',
        name: 'manage',
      );

  String get your_tasks => Intl.message(
        'Sus tareas',
        name: 'your_tasks',
      );

  String get your_groups => Intl.message(
        'Tus grupos',
        name: 'your_groups',
      );

  String get pending => Intl.message(
        'Pendiente',
        name: 'pending',
      );

  String get not_accepted => Intl.message(
        'No aceptada',
        name: 'not_accepted',
      );

  String get completed => Intl.message(
        'Terminado',
        name: 'completed',
      );

  String get protected_timebank => Intl.message(
        'Banco de tiempo protegido',
        name: 'protected_timebank',
      );

  String get protected_timebank_group_creation_error => Intl.message(
        'No puede crear grupos en un banco de tiempo protegido',
        name: 'protected_timebank_group_creation_error',
      );

  String get groups_help_text => Intl.message(
        'Ayuda de grupos',
        name: 'groups_help_text',
      );

  String get payment_data_syncing => Intl.message(
        'Sincronización de datos de pago',
        name: 'payment_data_syncing',
      );

  String get actions_not_allowed => Intl.message(
        'Acciones no permitidas, comuníquese con el administrador',
        name: 'actions_not_allowed',
      );

  String get configure_billing => Intl.message(
        'Configurar facturación',
        name: 'configure_billing',
      );

  String get limit_badge_contact_admin => Intl.message(
        'Acción no permitida, comuníquese con el administrador',
        name: 'limit_badge_contact_admin',
      );

  String get limit_badge_billing_failed => Intl.message(
        'Facturación fallida, haga clic a continuación para configurar la facturación',
        name: 'limit_badge_billing_failed',
      );

  String get limit_badge_delete_in_progress => Intl.message(
        'Hemos recibido su solicitud de eliminación. Estamos procesando la solicitud. Se le notificará una vez que se complete.',
        name: 'limit_badge_delete_in_progress',
      );

  String get bottom_nav_explore => Intl.message(
        'Explorar',
        name: 'bottom_nav_explore',
      );

  String get bottom_nav_notifications => Intl.message(
        'Notificaciones',
        name: 'bottom_nav_notifications',
      );

  String get bottom_nav_home => Intl.message(
        'Hogar',
        name: 'bottom_nav_home',
      );

  String get bottom_nav_messages => Intl.message(
        'Mensajes',
        name: 'bottom_nav_messages',
      );

  String get bottom_nav_profile => Intl.message(
        'Perfil',
        name: 'bottom_nav_profile',
      );

  String get ok => Intl.message(
        'Okay',
        name: 'ok',
      );

  String get no_group_message => Intl.message(
        'Los grupos te ayudan a organizar tus actividades específicas, no tienes ninguna. Tratar',
        name: 'no_group_message',
      );

  String get creating_one => Intl.message(
        'creando uno',
        name: 'creating_one',
      );

  String get general_stream_error => Intl.message(
        'Algo salió mal. Por favor, vuelva a intentarlo',
        name: 'general_stream_error',
      );

  String get no_pending_task => Intl.message(
        'Sin tareas pendientes',
        name: 'no_pending_task',
      );

  String get from => Intl.message(
        'De',
        name: 'from',
      );

  String get until => Intl.message(
        'Hasta',
        name: 'until',
      );

  String get posted_by => Intl.message(
        'Publicado por',
        name: 'posted_by',
      );

  String get posted_date => Intl.message(
        'Fecha de publicación',
        name: 'posted_date',
      );

  String get enter_hours => Intl.message(
        'Ingrese horas',
        name: 'enter_hours',
      );

  String get select_hours => Intl.message(
        'Seleccionar horas',
        name: 'select_hours',
      );

  String hour(num count) => Intl.message(
        '${Intl.plural(count, one: '${Intl.plural(count, one: 'Hora', other: 'Horas', args: [count])}', args: [count])}',
        name: 'hour',        
        args: [count],
      );

  String get validation_error_task_minutes => Intl.message(
        'Los minutos no pueden estar vacíos',
        name: 'validation_error_task_minutes',
      );

  String get minutes => Intl.message(
        'minutos',
        name: 'minutes',
      );

  String get limit_exceeded => Intl.message(
        '¡Límite excedido!',
        name: 'limit_exceeded',
      );

  String get task_max_hours_of_credit => Intl.message(
        'Horas de crédito de esta solicitud.',
        name: 'task_max_hours_of_credit',
      );

  String get validation_error_invalid_hours => Intl.message(
        '¡Ingrese un número válido de horas!',
        name: 'validation_error_invalid_hours',
      );

  String get please_wait => Intl.message(
        'Por favor espera...',
        name: 'please_wait',
      );

  String get task_max_request_message => Intl.message(
        'Solo puedes solicitar un máximo de',
        name: 'task_max_request_message',
      );

  String get there_are_currently_none => Intl.message(
        'Actualmente no hay ninguno',
        name: 'there_are_currently_none',
      );

  String get no_completed_task => Intl.message(
        'No has completado ninguna tarea.',
        name: 'no_completed_task',
      );

  String get completed_tasks => Intl.message(
        'Tareas completadas',
        name: 'completed_tasks',
      );

  String get seva_credits => Intl.message(
        'Créditos Seva',
        name: 'seva_credits',
      );

  String get no_notifications => Intl.message(
        'No Notificaciones',
        name: 'no_notifications',
      );

  String get personal => Intl.message(
        'Personal',
        name: 'personal',
      );

  String get notifications_signed_up_for => Intl.message(
        'Te habías apuntado',
        name: 'notifications_signed_up_for',
      );

  String get on => Intl.message(
        'en',
        name: 'on',
      );

  String get notifications_event_modification => Intl.message(
        '. El propietario del evento ha modificado este evento. Asegúrese de que los cambios realizados sean adecuados para usted y vuelva a aplicar.',
        name: 'notifications_event_modification',
      );

  String get notification_timebank_join => Intl.message(
        'Unirse al banco de tiempo',
        name: 'notification_timebank_join',
      );

  String get notifications_added_you => Intl.message(
        'te ha agregado a',
        name: 'notifications_added_you',
      );

  String get notifications_request_rejected_by => Intl.message(
        'Solicitud rechazada por',
        name: 'notifications_request_rejected_by',
      );

  String get notifications_join_request => Intl.message(
        'Solicitud de unión',
        name: 'notifications_join_request',
      );

  String get notifications_requested_join => Intl.message(
        'te ha pedido que te unas',
        name: 'notifications_requested_join',
      );

  String get notifications_tap_to_view => Intl.message(
        'Toque para ver la solicitud para unirse',
        name: 'notifications_tap_to_view',
      );

  String get notifications_task_rejected_by => Intl.message(
        'Finalización de la tarea rechazada por',
        name: 'notifications_task_rejected_by',
      );

  String get notifications_approved_for => Intl.message(
        'aprobó la finalización de la tarea para',
        name: 'notifications_approved_for',
      );

  String get notifications_credited => Intl.message(
        'Acreditado',
        name: 'notifications_credited',
      );

  String get notifications_credited_to => Intl.message(
        'han sido acreditados en su cuenta.',
        name: 'notifications_credited_to',
      );

  String get congrats => Intl.message(
        'Felicidades',
        name: 'congrats',
      );

  String get notifications_debited => Intl.message(
        'Debitado',
        name: 'notifications_debited',
      );

  String get notifications_debited_to => Intl.message(
        'ha sido debitado de su cuenta',
        name: 'notifications_debited_to',
      );

  String get notifications_offer_accepted => Intl.message(
        'Oferta aceptada',
        name: 'notifications_offer_accepted',
      );

  String get notifications_shown_interest => Intl.message(
        'ha mostrado interés en tu oferta',
        name: 'notifications_shown_interest',
      );

  String get notifications_invited_to_join => Intl.message(
        'te ha invitado a unirte',
        name: 'notifications_invited_to_join',
      );

  String get notifications_group_join_invite => Intl.message(
        'Invitación para unirse al grupo',
        name: 'notifications_group_join_invite',
      );

  String get notifications_new_member_signup => Intl.message(
        'Nuevo miembro registrado',
        name: 'notifications_new_member_signup',
      );

  String get notifications_credits_for => Intl.message(
        'Créditos para',
        name: 'notifications_credits_for',
      );

  String get notifications_signed_for_class => Intl.message(
        'Inscrito en clase',
        name: 'notifications_signed_for_class',
      );

  String get notifications_feedback_request => Intl.message(
        'Solicitud de comentarios',
        name: 'notifications_feedback_request',
      );

  String get notifications_was_deleted => Intl.message(
        '¡fué borrado!',
        name: 'notifications_was_deleted',
      );

  String get notifications_could_not_delete => Intl.message(
        'no se pudo borrar!',
        name: 'notifications_could_not_delete',
      );

  String get notifications_successfully_deleted => Intl.message(
        '*** se ha eliminado correctamente.',
        name: 'notifications_successfully_deleted',
      );

  String get notifications_could_not_deleted => Intl.message(
        'no se pudo eliminar porque tiene transacciones pendientes.',
        name: 'notifications_could_not_deleted',
      );

  String get notifications_incomplete_transaction => Intl.message(
        'No pudimos procesar su solicitud de eliminación de ***, ya que todavía tiene transacciones abiertas que son como:',
        name: 'notifications_incomplete_transaction',
      );

  String get one_to_many_offers => Intl.message(
        'una a muchas ofertas',
        name: 'one_to_many_offers',
      );

  String get open_requests => Intl.message(
        'solicitudes abiertas',
        name: 'open_requests',
      );

  String get delete => Intl.message(
        'Eliminar',
        name: 'delete',
      );

  String get delete_notification => Intl.message(
        'Eliminar notificación',
        name: 'delete_notification',
      );

  String get delete_notification_confirmation => Intl.message(
        '¿Está seguro de que desea eliminar esta notificación?',
        name: 'delete_notification_confirmation',
      );

  String get notifications_approved_by => Intl.message(
        'Solicitud aprobada por',
        name: 'notifications_approved_by',
      );

  String get notifications_request_accepted_by => Intl.message(
        'Solicitud aceptada por',
        name: 'notifications_request_accepted_by',
      );

  String get notifications_waiting_for_approval => Intl.message(
        'esperando su aprobación.',
        name: 'notifications_waiting_for_approval',
      );

  String get notifications_by_approving => Intl.message(
        'Aprobando',
        name: 'notifications_by_approving',
      );

  String get notifications_will_be_added_to => Intl.message(
        'se agregará al evento',
        name: 'notifications_will_be_added_to',
      );

  String get approve => Intl.message(
        'Aprobar',
        name: 'approve',
      );

  String get decline => Intl.message(
        'Disminución',
        name: 'decline',
      );

  String get bio_not_updated => Intl.message(
        'Biografía aún no actualizada',
        name: 'bio_not_updated',
      );

  String get start_new_post => Intl.message(
        'Iniciar una nueva publicación ...',
        name: 'start_new_post',
      );

  String get gps_on_reminder => Intl.message(
        'Asegúrate de tener el GPS activado.',
        name: 'gps_on_reminder',
      );

  String get empty_feed => Intl.message(
        'Tu feed está vacío',
        name: 'empty_feed',
      );

  String get report_feed => Intl.message(
        'Feed de informes',
        name: 'report_feed',
      );

  String get report_feed_confirmation_message => Intl.message(
        '¿Quieres denunciar este feed?',
        name: 'report_feed_confirmation_message',
      );

  String get already_reported => Intl.message(
        '¡Ya informado!',
        name: 'already_reported',
      );

  String get feed_reported => Intl.message(
        'Ya denunciaste este feed',
        name: 'feed_reported',
      );

  String get no_projects_message => Intl.message(
        'No hay proyectos disponibles.',
        name: 'no_projects_message',
      );

  String get help => Intl.message(
        'Ayuda',
        name: 'help',
      );

  String get tasks => Intl.message(
        'Tareas',
        name: 'tasks',
      );

  String get my_requests => Intl.message(
        'Mis solicitudes',
        name: 'my_requests',
      );

  String get select_request => Intl.message(
        'Seleccionar solicitud',
        name: 'select_request',
      );

  String get protected_timebank_request_creation_error => Intl.message(
        'No puede publicar solicitudes en un banco de tiempo protegido',
        name: 'protected_timebank_request_creation_error',
      );

  String get request_delete_confirmation_message => Intl.message(
        '¿Está seguro de que desea eliminar esta solicitud?',
        name: 'request_delete_confirmation_message',
      );

  String get no => Intl.message(
        'No',
        name: 'no',
      );

  String get yes => Intl.message(
        'si',
        name: 'yes',
      );

  String get number_of_volunteers_required => Intl.message(
        'Número de voluntarios necesarios',
        name: 'number_of_volunteers_required',
      );

  String get withdraw => Intl.message(
        'Retirar',
        name: 'withdraw',
      );

  String get accept => Intl.message(
        'Aceptar',
        name: 'accept',
      );

  String get no_approved_members => Intl.message(
        'Aún no hay miembros aprobados.',
        name: 'no_approved_members',
      );

  String get view_approved_members => Intl.message(
        'Ver miembros aprobados',
        name: 'view_approved_members',
      );

  String get request => Intl.message(
        'Solicitud',
        name: 'request',
      );

  String get applied => Intl.message(
        'Aplicado',
        name: 'applied',
      );

  String get accepted => Intl.message(
        'Aceptado',
        name: 'accepted',
      );

  String get default_text => Intl.message(
        'Defecto',
        name: 'default_text',
      );

  String get access_denied => Intl.message(
        'Acceso denegado.',
        name: 'access_denied',
      );

  String get not_authorized_create_request => Intl.message(
        'No está autorizado para crear una solicitud.',
        name: 'not_authorized_create_request',
      );

  String get add_requests => Intl.message(
        'Agregar solicitudes',
        name: 'add_requests',
      );

  String get no_requests_available => Intl.message(
        'No hay solicitudes disponibles.',
        name: 'no_requests_available',
      );

  String get fetching_location => Intl.message(
        'Obteniendo ubicación',
        name: 'fetching_location',
      );

  String get edit => Intl.message(
        'Editar',
        name: 'edit',
      );

  String get title => Intl.message(
        'Título',
        name: 'title',
      );

  String get mission_statement => Intl.message(
        'Estado de la misión',
        name: 'mission_statement',
      );

  String get organizer => Intl.message(
        'Organizador',
        name: 'organizer',
      );

  String get delete_project => Intl.message(
        'Eliminar proyecto',
        name: 'delete_project',
      );

  String get create_project => Intl.message(
        'Crear un proyecto',
        name: 'create_project',
      );

  String get edit_project => Intl.message(
        'Editar proyecto',
        name: 'edit_project',
      );

  String timebank_project(num count) => Intl.message(
        '${Intl.plural(count, one: '${Intl.plural(count, one: 'Proyecto de banco de tiempo', other: 'Proyectos de banco de tiempo', args: [count])}', args: [count])}',
        name: 'timebank_project',        
        args: [count],
      );

  String personal_project(num count) => Intl.message(
        '${Intl.plural(count, one: '${Intl.plural(count, one: 'Proyecto personal', other: 'Proyectos personales', args: [count])}', args: [count])}',
        name: 'personal_project',        
        args: [count],
      );

  String get project_logo => Intl.message(
        'Logotipo del proyecto',
        name: 'project_logo',
      );

  String get project_name => Intl.message(
        'Nombre del proyecto',
        name: 'project_name',
      );

  String get name_hint => Intl.message(
        'Ej .: Mascotas en la ciudad, colaboración ciudadana',
        name: 'name_hint',
      );

  String get validation_error_project_name_empty => Intl.message(
        'El nombre del proyecto no puede estar vacío',
        name: 'validation_error_project_name_empty',
      );

  String get project_duration => Intl.message(
        'Duración del proyecto',
        name: 'project_duration',
      );

  String get project_mission_statement_hint => Intl.message(
        'Ej: Un poco más sobre su proyecto que ayudará a asociarse con',
        name: 'project_mission_statement_hint',
      );

  String get validation_error_mission_empty => Intl.message(
        'La declaración de misión no puede estar vacía.',
        name: 'validation_error_mission_empty',
      );

  String get email_hint => Intl.message(
        'example@example.com',
        name: 'email_hint',
      );

  String get phone_number => Intl.message(
        'Número de teléfono',
        name: 'phone_number',
      );

  String get project_location => Intl.message(
        'La ubicación de su proyecto.',
        name: 'project_location',
      );

  String get project_location_hint => Intl.message(
        'La ubicación del proyecto ayudará a sus miembros a ubicar',
        name: 'project_location_hint',
      );

  String get save_as_template => Intl.message(
        'Guardar como plantilla',
        name: 'save_as_template',
      );

  String get validation_error_no_date => Intl.message(
        'Mencione la fecha de inicio y finalización del proyecto.',
        name: 'validation_error_no_date',
      );

  String get creating_project => Intl.message(
        'Creando proyecto',
        name: 'creating_project',
      );

  String get validation_error_location_mandatory => Intl.message(
        'La ubicación es obligatoria',
        name: 'validation_error_location_mandatory',
      );

  String get validation_error_add_project_location => Intl.message(
        'Agregue una ubicación a su proyecto',
        name: 'validation_error_add_project_location',
      );

  String get updating_project => Intl.message(
        'Actualización del proyecto',
        name: 'updating_project',
      );

  String get save => Intl.message(
        'Salvar',
        name: 'save',
      );

  String get template_title => Intl.message(
        'Proporcione un nombre único para la plantilla',
        name: 'template_title',
      );

  String get template_hint => Intl.message(
        'Nombre de la plantilla',
        name: 'template_hint',
      );

  String get validation_error_template_name => Intl.message(
        'El nombre de la plantilla no puede estar vacío',
        name: 'validation_error_template_name',
      );

  String get validation_error_template_name_exists => Intl.message(
        'El nombre de la plantilla ya está en uso. Proporcione otro nombre',
        name: 'validation_error_template_name_exists',
      );

  String get add_location => Intl.message(
        'Añade una ubicación',
        name: 'add_location',
      );

  String get delete_confirmation => Intl.message(
        '¿Estás seguro de que quieres eliminar?',
        name: 'delete_confirmation',
      );

  String get accidental_delete_enabled => Intl.message(
        'Eliminación accidental habilitada',
        name: 'accidental_delete_enabled',
      );

  String get accidental_delete_enabled_description => Intl.message(
        'Esta ** tiene habilitada la opción \"Evitar eliminación accidental\". Desmarque esa casilla (en la pestaña \"Administrar\") antes de intentar eliminar **.',
        name: 'accidental_delete_enabled_description',
      );

  String get deletion_request_being_processed => Intl.message(
        'Se está procesando su solicitud de eliminación.',
        name: 'deletion_request_being_processed',
      );

  String get deletion_request_progress_description => Intl.message(
        'Hemos recibido su solicitud de eliminación. Estamos procesando la solicitud. Se le notificará una vez que se complete.',
        name: 'deletion_request_progress_description',
      );

  String get submitting_request => Intl.message(
        'Enviando solicitud ...',
        name: 'submitting_request',
      );

  String get advisory_for_timebank => Intl.message(
        '¡Se eliminará toda la información relevante, incluidos proyectos, solicitudes y ofertas del grupo!',
        name: 'advisory_for_timebank',
      );

  String get advisory_for_projects => Intl.message(
        'Se eliminarán todas las solicitudes asociadas a esta solicitud',
        name: 'advisory_for_projects',
      );

  String get deletion_request_recieved => Intl.message(
        'Hemos recibido su solicitud para eliminar este ***. Lamentamos que te vayas. Examinaremos su solicitud y (en algunos casos) nos pondremos en contacto con usted fuera de línea antes de procesar la eliminación del ***',
        name: 'deletion_request_recieved',
      );

  String get request_submitted => Intl.message(
        'Solicitud enviada',
        name: 'request_submitted',
      );

  String get request_failed => Intl.message(
        '¡Solicitud fallida!',
        name: 'request_failed',
      );

  String get request_failure_message => Intl.message(
        'El envío de la solicitud falló de alguna manera. Vuelve a intentarlo más tarde.',
        name: 'request_failure_message',
      );

  String get hosted_by => Intl.message(
        'Alojado por',
        name: 'hosted_by',
      );

  String get creator_of_request_message => Intl.message(
        'Eres el creador de esta solicitud.',
        name: 'creator_of_request_message',
      );

  String get applied_for_request => Intl.message(
        'Ha solicitado la solicitud.',
        name: 'applied_for_request',
      );

  String get particpate_in_request_question => Intl.message(
        '¿Quieres participar en esta solicitud?',
        name: 'particpate_in_request_question',
      );

  String get apply => Intl.message(
        'Aplicar',
        name: 'apply',
      );

  String get protected_timebank_alert_dialog => Intl.message(
        'No puede aceptar solicitudes en un banco de tiempo protegido',
        name: 'protected_timebank_alert_dialog',
      );

  String get already_approved => Intl.message(
        'Ya está aprovado',
        name: 'already_approved',
      );

  String get withdraw_request_failure => Intl.message(
        'No puede retirar la solicitud porque ya está aprobada',
        name: 'withdraw_request_failure',
      );

  String get find_volunteers => Intl.message(
        'Encuentra voluntarios',
        name: 'find_volunteers',
      );

  String get invited => Intl.message(
        'Invitado',
        name: 'invited',
      );

  String get favourites => Intl.message(
        'Favoritos',
        name: 'favourites',
      );

  String get past_hired => Intl.message(
        'Contratado anteriormente',
        name: 'past_hired',
      );

  String get type_team_member_name => Intl.message(
        'Escriba el nombre de los miembros de su equipo',
        name: 'type_team_member_name',
      );

  String get validation_error_search_min_characters => Intl.message(
        'La búsqueda requiere un mínimo de 3 caracteres',
        name: 'validation_error_search_min_characters',
      );

  String get no_user_found => Intl.message(
        'Usuario no encontrado',
        name: 'no_user_found',
      );

  String get approved => Intl.message(
        'Aprobado',
        name: 'approved',
      );

  String get invite => Intl.message(
        'Invitación',
        name: 'invite',
      );

  String get name_not_available => Intl.message(
        'El nombre no está disponible',
        name: 'name_not_available',
      );

  String get create_request => Intl.message(
        'Crear solicitud',
        name: 'create_request',
      );

  String get create_project_request => Intl.message(
        'Crear solicitud de proyecto',
        name: 'create_project_request',
      );

  String get set_duration => Intl.message(
        'Haga clic para establecer la duración',
        name: 'set_duration',
      );

  String get request_title => Intl.message(
        'Título de la solicitud *',
        name: 'request_title',
      );

  String get request_title_hint => Intl.message(
        'Ej: Pequeños trabajos de carpintería ...',
        name: 'request_title_hint',
      );

  String get request_subject => Intl.message(
        'Por favor ingrese el asunto de su solicitud',
        name: 'request_subject',
      );

  String get request_duration => Intl.message(
        'Duración de la solicitud',
        name: 'request_duration',
      );

  String get request_description => Intl.message(
        'Solicitar descripción *',
        name: 'request_description',
      );

  String get request_description_hint => Intl.message(
        'Su solicitud y cualquier #hashtags',
        name: 'request_description_hint',
      );

  String get number_of_volunteers => Intl.message(
        'No de voluntarios *',
        name: 'number_of_volunteers',
      );

  String get validation_error_volunteer_count => Intl.message(
        'Ingrese el número de voluntarios necesarios',
        name: 'validation_error_volunteer_count',
      );

  String get validation_error_volunteer_count_negative => Intl.message(
        'El número de voluntarios no puede ser inferior a 0',
        name: 'validation_error_volunteer_count_negative',
      );

  String get validation_error_volunteer_count_zero => Intl.message(
        'El número de voluntarios no puede ser 0',
        name: 'validation_error_volunteer_count_zero',
      );

  String personal_request(num count) => Intl.message(
        '${Intl.plural(count, one: '${Intl.plural(count, one: 'Solicitud personal', other: 'Solicitudes personales', args: [count])}', args: [count])}',
        name: 'personal_request',        
        args: [count],
      );

  String timebank_request(num count) => Intl.message(
        '${Intl.plural(count, one: '${Intl.plural(count, one: 'Solicitud de banco de tiempo', other: 'Solicitudes de banco de tiempo', args: [count])}', args: [count])}',
        name: 'timebank_request',        
        args: [count],
      );

  String get validation_error_same_start_date_end_date => Intl.message(
        'Ha proporcionado una fecha y hora idénticas para el inicio y el final. Proporcione una hora de finalización posterior a la hora de inicio.',
        name: 'validation_error_same_start_date_end_date',
      );

  String get validation_error_empty_recurring_days => Intl.message(
        'Los días recurrentes no pueden estar vacíos',
        name: 'validation_error_empty_recurring_days',
      );

  String get creating_request => Intl.message(
        'Crear solicitud',
        name: 'creating_request',
      );

  String get updating_request => Intl.message(
        'Solicitud de actualización',
        name: 'updating_request',
      );

  String get insufficient_credits_for_request => Intl.message(
        'Sus créditos seva no son suficientes para crear la solicitud.',
        name: 'insufficient_credits_for_request',
      );

  String get assign_to_volunteers => Intl.message(
        'Asignar a voluntarios',
        name: 'assign_to_volunteers',
      );

  String members_selected(num count) => Intl.message(
        '${Intl.plural(count, one: '${Intl.plural(count, one: 'Miembro seleccionado', other: 'Miembros seleccionados', args: [count])}', args: [count])}',
        name: 'members_selected',        
        args: [count],
      );

  String volunteers_selected(num count) => Intl.message(
        '${Intl.plural(count, one: '${Intl.plural(count, one: 'Voluntario seleccionado', other: 'Voluntarios seleccionados', args: [count])}', args: [count])}',
        name: 'volunteers_selected',        
        args: [count],
      );

  String get timebank_max_seva_credit_message1 => Intl.message(
        'Los Créditos Seva se acreditarán al Banco de Tiempo para esta solicitud. Tenga en cuenta que cada participante recibirá un máximo de',
        name: 'timebank_max_seva_credit_message1',
      );

  String get timebank_max_seva_credit_message2 => Intl.message(
        'créditos por completar esta solicitud.',
        name: 'timebank_max_seva_credit_message2',
      );

  String get personal_max_seva_credit_message1 => Intl.message(
        'Se requieren créditos Seva para esta solicitud. Se debitará de su saldo. Tenga en cuenta que cada participante recibirá un máximo de',
        name: 'personal_max_seva_credit_message1',
      );

  String get personal_max_seva_credit_message2 => Intl.message(
        'créditos por completar esta solicitud.',
        name: 'personal_max_seva_credit_message2',
      );

  String get unassigned => Intl.message(
        'Sin asignar',
        name: 'unassigned',
      );

  String get assign_to_project => Intl.message(
        'Asignar al proyecto',
        name: 'assign_to_project',
      );

  String get assign_to_one_project => Intl.message(
        'Asignar a un proyecto',
        name: 'assign_to_one_project',
      );

  String get tap_to_select => Intl.message(
        'Toque para seleccionar uno o más ...',
        name: 'tap_to_select',
      );

  String get repeat => Intl.message(
        'Repetir',
        name: 'repeat',
      );

  String get repeat_on => Intl.message(
        'Repetir en',
        name: 'repeat_on',
      );

  String get ends => Intl.message(
        'Termina',
        name: 'ends',
      );

  String get after => Intl.message(
        'Después',
        name: 'after',
      );

  String get occurences => Intl.message(
        'Ocurrencias',
        name: 'occurences',
      );

  String get done => Intl.message(
        'Hecho',
        name: 'done',
      );

  String get date_time => Intl.message(
        'fecha y hora',
        name: 'date_time',
      );

  String get start => Intl.message(
        'comienzo',
        name: 'start',
      );

  String get end => Intl.message(
        'End',
        name: 'end',
      );

  String get time => Intl.message(
        'Hora',
        name: 'time',
      );

  String get date_selection_issue => Intl.message(
        'Problema de selección de fecha',
        name: 'date_selection_issue',
      );

  String get validation_error_end_date_greater => Intl.message(
        'La fecha de finalización no puede ser anterior a la fecha de inicio',
        name: 'validation_error_end_date_greater',
      );

  String get unblock => Intl.message(
        'Unblock',
        name: 'unblock',
      );

  String get no_blocked_members => Intl.message(
        'No blocked members',
        name: 'no_blocked_members',
      );

  String get blocked_members => Intl.message(
        'Blocked Members',
        name: 'blocked_members',
      );

  String get confirm_location => Intl.message(
        'confirmar ubicación',
        name: 'confirm_location',
      );

  String get no_message => Intl.message(
        'Ningún mensaje',
        name: 'no_message',
      );

  String get reject_task_completion => Intl.message(
        'I am rejecting your task completion request because',
        name: 'reject_task_completion',
      );

  String get type_message => Intl.message(
        'Escribe un mensaje',
        name: 'type_message',
      );

  String get failed_to_load_post => Intl.message(
        'Couldn\'t load the post!',
        name: 'failed_to_load_post',
      );

  String get admin => Intl.message(
        'Administración',
        name: 'admin',
      );

  String get new_message_room => Intl.message(
        'Nueva sala de mensajes',
        name: 'new_message_room',
      );

  String get messaging_room_name => Intl.message(
        'Nombre de la sala de mensajería',
        name: 'messaging_room_name',
      );

  String get new_chat => Intl.message(
        'Nueva conversación',
        name: 'new_chat',
      );

  String get frequently_contacted => Intl.message(
        'CONTACTADO CON FRECUENCIA',
        name: 'frequently_contacted',
      );

  String get groups => Intl.message(
        'Grupos',
        name: 'groups',
      );

  String get timebank_members => Intl.message(
        'Timebank Members',
        name: 'timebank_members',
      );

  String get add_participants => Intl.message(
        'Add Participants',
        name: 'add_participants',
      );

  String get participants => Intl.message(
        'Participantes',
        name: 'participants',
      );

  String get messaging_room => Intl.message(
        'Messaging Room',
        name: 'messaging_room',
      );

  String get creating_messaging_room => Intl.message(
        'Creando habitación ...',
        name: 'creating_messaging_room',
      );

  String get updating_messaging_room => Intl.message(
        'Actualizando Room ...',
        name: 'updating_messaging_room',
      );

  String get messaging_room_note => Intl.message(
        'Proporcione un asunto de la sala de mensajes y un icono de grupo opcional',
        name: 'messaging_room_note',
      );

  String get exit_messaging_room => Intl.message(
        'Salir de la sala de mensajes',
        name: 'exit_messaging_room',
      );

  String get exit_messaging_room_admin_confirmation => Intl.message(
        'Eres administrador de esta sala de mensajería, ¿estás seguro de que deseas salir de la sala de mensajería?',
        name: 'exit_messaging_room_admin_confirmation',
      );

  String get no_frequent_contacts => Intl.message(
        'Sin contactos frecuentes',
        name: 'no_frequent_contacts',
      );

  String get sending => Intl.message(
        'Enviando...',
        name: 'sending',
      );

  String get create => Intl.message(
        'Crear',
        name: 'create',
      );

  String get add_caption => Intl.message(
        'Add a caption',
        name: 'add_caption',
      );

  String get tap_for_photo => Intl.message(
        'Tap for photo',
        name: 'tap_for_photo',
      );

  String get validation_error_room_name => Intl.message(
        'Name can\'t be empty',
        name: 'validation_error_room_name',
      );

  String get chat_block_warning => Intl.message(
        'will no longer be available to send you messages and engage with the content you create',
        name: 'chat_block_warning',
      );

  String get delete_chat_confirmation => Intl.message(
        'Are you sure you want to delete this chat',
        name: 'delete_chat_confirmation',
      );

  String get block => Intl.message(
        'Block',
        name: 'block',
      );

  String get exit_messaging_room_user_confirmation => Intl.message(
        'Are you sure you want to exit the Messaging room',
        name: 'exit_messaging_room_user_confirmation',
      );

  String get exit => Intl.message(
        'Salida',
        name: 'exit',
      );

  String get delete_chat => Intl.message(
        'Eliminar chat',
        name: 'delete_chat',
      );

  String get group => Intl.message(
        'Group',
        name: 'group',
      );

  String get shared_post => Intl.message(
        'Shared a post',
        name: 'shared_post',
      );

  String get change_ownership => Intl.message(
        'Change Ownership',
        name: 'change_ownership',
      );

  String get change_ownership_invite => Intl.message(
        'has invited you to be the new owner of the Timebank',
        name: 'change_ownership_invite',
      );

  String get notifications_insufficient_credits => Intl.message(
        'Sus créditos seva no son suficientes para aprobar la solicitud de crédito.',
        name: 'notifications_insufficient_credits',
      );

  String get completed_task_in => Intl.message(
        'completed the task in',
        name: 'completed_task_in',
      );

  String get by_approving_you_accept => Intl.message(
        'By approving, you accept that',
        name: 'by_approving_you_accept',
      );

  String get reject => Intl.message(
        'Rechazar',
        name: 'reject',
      );

  String get no_comments => Intl.message(
        'No Comments',
        name: 'no_comments',
      );

  String get reason_to_join => Intl.message(
        'Reason to join',
        name: 'reason_to_join',
      );

  String get reason_not_mentioned => Intl.message(
        'Reason not mentioned',
        name: 'reason_not_mentioned',
      );

  String get allow => Intl.message(
        'Allow',
        name: 'allow',
      );

  String get updating_timebank => Intl.message(
        'Updating Timebank..',
        name: 'updating_timebank',
      );

  String get no_bookmarked_offers => Intl.message(
        'No offers bookmarked',
        name: 'no_bookmarked_offers',
      );

  String get create_offer => Intl.message(
        'Create Offer',
        name: 'create_offer',
      );

  String get individual_offer => Intl.message(
        'Individual offer',
        name: 'individual_offer',
      );

  String get one_to_many => Intl.message(
        'One to many',
        name: 'one_to_many',
      );

  String get update_offer => Intl.message(
        'Update Offer',
        name: 'update_offer',
      );

  String get creating_offer => Intl.message(
        'Creating offer',
        name: 'creating_offer',
      );

  String get updating_offer => Intl.message(
        'Updating offer',
        name: 'updating_offer',
      );

  String get offer_error_creating => Intl.message(
        'Se produjo un error al crear su oferta. Vuelva a intentarlo.',
        name: 'offer_error_creating',
      );

  String get offer_error_updating => Intl.message(
        'There was error updating offer, Please try again.',
        name: 'offer_error_updating',
      );

  String get offer_title_hint => Intl.message(
        'Ex babysitting',
        name: 'offer_title_hint',
      );

  String get offer_description => Intl.message(
        'Offer description',
        name: 'offer_description',
      );

  String get offer_description_hint => Intl.message(
        'Your offer and any #hashtags',
        name: 'offer_description_hint',
      );

  String get availablity => Intl.message(
        'Availability',
        name: 'availablity',
      );

  String get availablity_description => Intl.message(
        'Describe my availability',
        name: 'availablity_description',
      );

  String get one_to_many_offer_hint => Intl.message(
        'Ex teaching a python class..',
        name: 'one_to_many_offer_hint',
      );

  String get offer_duration => Intl.message(
        'Offer duration',
        name: 'offer_duration',
      );

  String get offer_prep_hours => Intl.message(
        'No. of preparation hours',
        name: 'offer_prep_hours',
      );

  String get offer_prep_hours_required => Intl.message(
        'No. of preparation hours required',
        name: 'offer_prep_hours_required',
      );

  String get offer_number_class_hours => Intl.message(
        'No. of class hours',
        name: 'offer_number_class_hours',
      );

  String get offer_number_class_hours_required => Intl.message(
        'No. of class hours required',
        name: 'offer_number_class_hours_required',
      );

  String get offer_size_class => Intl.message(
        'Size of class',
        name: 'offer_size_class',
      );

  String get offer_enter_participants => Intl.message(
        'Enter the number of participants',
        name: 'offer_enter_participants',
      );

  String get offer_class_description => Intl.message(
        'Class description',
        name: 'offer_class_description',
      );

  String get offer_description_error => Intl.message(
        'Please enter some class description',
        name: 'offer_description_error',
      );

  String get offer_start_end_date => Intl.message(
        'Please enter start and end date',
        name: 'offer_start_end_date',
      );

  String get validation_error_offer_title => Intl.message(
        'Please enter the subject of your offer',
        name: 'validation_error_offer_title',
      );

  String get validation_error_offer_class_hours => Intl.message(
        'Please enter the hours required for the class',
        name: 'validation_error_offer_class_hours',
      );

  String get validation_error_hours_not_int => Intl.message(
        'Entered number of hours is not valid',
        name: 'validation_error_hours_not_int',
      );

  String get validation_error_offer_prep_hour => Intl.message(
        'Please enter your preperation time',
        name: 'validation_error_offer_prep_hour',
      );

  String get validation_error_location => Intl.message(
        'Please select location',
        name: 'validation_error_location',
      );

  String get validation_error_class_size_int => Intl.message(
        'Size of class can\'t be in decimal',
        name: 'validation_error_class_size_int',
      );

  String get validation_error_class_size => Intl.message(
        'Please enter valid size of class',
        name: 'validation_error_class_size',
      );

  String get validation_error_offer_credit => Intl.message(
        'We cannot publish this Class. There are insufficient credits from the class. Please revise the Prep time or the number of students and submit the offer again',
        name: 'validation_error_offer_credit',
      );

  String get posted_on => Intl.message(
        'Posted on',
        name: 'posted_on',
      );

  String get location => Intl.message(
        'Location',
        name: 'location',
      );

  String get offered_by => Intl.message(
        'Offered by',
        name: 'offered_by',
      );

  String get you_created_offer => Intl.message(
        'You created this offer',
        name: 'you_created_offer',
      );

  String get you_have => Intl.message(
        'You have',
        name: 'you_have',
      );

  String get not_yet => Intl.message(
        'not yet',
        name: 'not_yet',
      );

  String get signed_up_for => Intl.message(
        'signed up for',
        name: 'signed_up_for',
      );

  String get bookmarked => Intl.message(
        'bookmarked',
        name: 'bookmarked',
      );

  String get this_offer => Intl.message(
        'this offer',
        name: 'this_offer',
      );

  String get details => Intl.message(
        'Details',
        name: 'details',
      );

  String get no_offers => Intl.message(
        'No Offers',
        name: 'no_offers',
      );

  String get your_earnings => Intl.message(
        'Your earnings',
        name: 'your_earnings',
      );

  String get timebank_earnings => Intl.message(
        'Timebank earnings',
        name: 'timebank_earnings',
      );

  String get no_participants_yet => Intl.message(
        'No Participants yet',
        name: 'no_participants_yet',
      );

  String get bookmarked_offers => Intl.message(
        'Bookmarked Offers',
        name: 'bookmarked_offers',
      );

  String get my_offers => Intl.message(
        'My Offers',
        name: 'my_offers',
      );

  String get offer_help => Intl.message(
        'Offers Help',
        name: 'offer_help',
      );

  String get report_members => Intl.message(
        'Report Member',
        name: 'report_members',
      );

  String get report_member_inform => Intl.message(
        'Please inform, why you are reporting this user.',
        name: 'report_member_inform',
      );

  String get report_member_provide_details => Intl.message(
        'Please provide as much detail as possible',
        name: 'report_member_provide_details',
      );

  String get report => Intl.message(
        'Report',
        name: 'report',
      );

  String get reporting_member => Intl.message(
        'Reporting member',
        name: 'reporting_member',
      );

  String get no_data => Intl.message(
        'Datos no encontrados !',
        name: 'no_data',
      );

  String get reported_by => Intl.message(
        'Reported by',
        name: 'reported_by',
      );

  String user(num count) => Intl.message(
        '${Intl.plural(count, one: '${Intl.plural(count, one: 'usuario', other: 'usuarios', args: [count])}', args: [count])}',
        name: 'user',        
        args: [count],
      );

  String get user_removed_from_group => Intl.message(
        'User is successfully removed from the group',
        name: 'user_removed_from_group',
      );

  String get user_removed_from_group_failed => Intl.message(
        'No se puede eliminar al usuario de este grupo',
        name: 'user_removed_from_group_failed',
      );

  String get user_has => Intl.message(
        'User has',
        name: 'user_has',
      );

  String get pending_projects => Intl.message(
        'pending projects',
        name: 'pending_projects',
      );

  String get pending_requests => Intl.message(
        'pending requests',
        name: 'pending_requests',
      );

  String get pending_offers => Intl.message(
        'ofertas pendientes',
        name: 'pending_offers',
      );

  String get clear_transaction => Intl.message(
        'Please clear the transactions and try again.',
        name: 'clear_transaction',
      );

  String get remove_self_from_group_error => Intl.message(
        'Cannot remove yourself from the group. Instead, please try deleting the group.',
        name: 'remove_self_from_group_error',
      );

  String get user_removed_from_timebank => Intl.message(
        'User is successfully removed from the Timebank',
        name: 'user_removed_from_timebank',
      );

  String get user_removed_from_timebank_failed => Intl.message(
        'User cannot be deleted from this Timebank',
        name: 'user_removed_from_timebank_failed',
      );

  String get member_reported => Intl.message(
        'Member reported successfully',
        name: 'member_reported',
      );

  String get member_reporting_failed => Intl.message(
        '¡No se pudo informar del miembro! Inténtalo de nuevo',
        name: 'member_reporting_failed',
      );

  String get reported_member_click_to_view => Intl.message(
        'Click here to view reported users of this Timebank',
        name: 'reported_member_click_to_view',
      );

  String get reported_users => Intl.message(
        'Usuarios reportados',
        name: 'reported_users',
      );

  String get reported_members => Intl.message(
        'Miembros reportados',
        name: 'reported_members',
      );

  String get search_something => Intl.message(
        'Search Something',
        name: 'search_something',
      );

  String get i_want_to_volunteer => Intl.message(
        'I want to volunteer.',
        name: 'i_want_to_volunteer',
      );

  String get help_about_us => Intl.message(
        'Sobre nosotros',
        name: 'help_about_us',
      );

  String get help_training_video => Intl.message(
        'Video de entrenamiento',
        name: 'help_training_video',
      );

  String get help_contact_us => Intl.message(
        'Contáctenos',
        name: 'help_contact_us',
      );

  String get help_version => Intl.message(
        'Version',
        name: 'help_version',
      );

  String get feedback => Intl.message(
        'Feedback',
        name: 'feedback',
      );

  String get send_feedback => Intl.message(
        'Enviar comentarios',
        name: 'send_feedback',
      );

  String get enter_feedback => Intl.message(
        'Please enter your feedback',
        name: 'enter_feedback',
      );

  String get feedback_messagae => Intl.message(
        'Please let us know about your valuable feedback',
        name: 'feedback_messagae',
      );

  String get create_timebank_description => Intl.message(
        'Un TimeBank es una comunidad de voluntarios que dan y reciben tiempo entre ellos y para la comunidad en general.',
        name: 'create_timebank_description',
      );

  String get timebank_logo => Intl.message(
        'Timebank Logo',
        name: 'timebank_logo',
      );

  String get timebank_name => Intl.message(
        'Name your Timebank',
        name: 'timebank_name',
      );

  String get timebank_name_hint => Intl.message(
        'Ex: Pets-in-town, Citizen collab',
        name: 'timebank_name_hint',
      );

  String get timebank_name_error => Intl.message(
        'Timebank name cannot be empty',
        name: 'timebank_name_error',
      );

  String get timebank_name_exists_error => Intl.message(
        'Elija otro nombre para el banco de tiempo. Este nombre de banco de tiempo ya existe',
        name: 'timebank_name_exists_error',
      );

  String get timbank_about_hint => Intl.message(
        'Ej: un poco más sobre su banco de tiempo',
        name: 'timbank_about_hint',
      );

  String get timebank_tell_more => Intl.message(
        'Cuéntanos más sobre tu banco de tiempo.',
        name: 'timebank_tell_more',
      );

  String get timebank_select_tax_percentage => Intl.message(
        'Seleccionar porcentaje de impuestos',
        name: 'timebank_select_tax_percentage',
      );

  String get timebank_current_tax_percentage => Intl.message(
        'Current Tax Percentage',
        name: 'timebank_current_tax_percentage',
      );

  String get timebank_location => Intl.message(
        'Your Timebank location.',
        name: 'timebank_location',
      );

  String get timebank_location_hint => Intl.message(
        'Indique el lugar o la dirección donde se reúne su comunidad (como un café, una biblioteca o una iglesia).',
        name: 'timebank_location_hint',
      );

  String get timebank_name_exists => Intl.message(
        'Timebank name already exists !',
        name: 'timebank_name_exists',
      );

  String get timebank_location_error => Intl.message(
        'Agrega la ubicación de tu banco de tiempo',
        name: 'timebank_location_error',
      );

  String get timebank_logo_error => Intl.message(
        'El logotipo de Timebank es obligatorio',
        name: 'timebank_logo_error',
      );

  String get creating_timebank => Intl.message(
        'Creating Timebank',
        name: 'creating_timebank',
      );

  String get timebank_billing_error => Intl.message(
        'Configure los detalles de su información personal',
        name: 'timebank_billing_error',
      );

  String get timebank_configure_profile_info => Intl.message(
        'Configurar la información del perfil',
        name: 'timebank_configure_profile_info',
      );

  String get timebank_profile_info => Intl.message(
        'información del perfil',
        name: 'timebank_profile_info',
      );

  String get validation_error_required_fields => Intl.message(
        'El campo no se puede dejar en blanco *',
        name: 'validation_error_required_fields',
      );

  String get state => Intl.message(
        'Estado',
        name: 'state',
      );

  String get city => Intl.message(
        'Ciudad',
        name: 'city',
      );

  String get zip => Intl.message(
        'Código Postal',
        name: 'zip',
      );

  String get country => Intl.message(
        'País',
        name: 'country',
      );

  String get street_add1 => Intl.message(
        'Dirección Calle 1',
        name: 'street_add1',
      );

  String get street_add2 => Intl.message(
        'Dirección 2',
        name: 'street_add2',
      );

  String get company_name => Intl.message(
        'Company name',
        name: 'company_name',
      );

  String get continue_text => Intl.message(
        'Continue',
        name: 'continue_text',
      );

  String get private_timebank => Intl.message(
        'Banco de tiempo privado',
        name: 'private_timebank',
      );

  String get updating_details => Intl.message(
        'Actualización de detalles',
        name: 'updating_details',
      );

  String get edit_profile_information => Intl.message(
        'Editar información de perfil',
        name: 'edit_profile_information',
      );

  String get selected_users_before => Intl.message(
        'Usuarios seleccionados antes',
        name: 'selected_users_before',
      );

  String get private_timebank_alert => Intl.message(
        'Alerta de banco de tiempo privado',
        name: 'private_timebank_alert',
      );

  String get private_timebank_alert_hint => Intl.message(
        'Tenga en cuenta que los bancos de tiempo privados no tienen una opción gratuita. Deberá proporcionar sus datos de facturación para continuar creando este banco de tiempo',
        name: 'private_timebank_alert_hint',
      );

  String get additional_notes => Intl.message(
        'Notas adicionales',
        name: 'additional_notes',
      );

  String get prevent_accidental_delete => Intl.message(
        'Evitar la eliminación accidental',
        name: 'prevent_accidental_delete',
      );

  String get update_request => Intl.message(
        'Solicitud de actualización',
        name: 'update_request',
      );

  String get timebank_offers => Intl.message(
        'Ofertas de Timebank',
        name: 'timebank_offers',
      );

  String other(num count) => Intl.message(
        '${Intl.plural(count, one: '${Intl.plural(count, one: 'Otro', other: 'Otros', args: [count])}', args: [count])}',
        name: 'other',        
        args: [count],
      );

  String get plan_details => Intl.message(
        'Detalles del plan',
        name: 'plan_details',
      );

  String get on_community_plan => Intl.message(
        'You are on Community Plan',
        name: 'on_community_plan',
      );

  String get change_plan => Intl.message(
        'cambio de plan',
        name: 'change_plan',
      );

  String get your_community_on_the => Intl.message(
        'Tu comunidad está en el',
        name: 'your_community_on_the',
      );

  String get plan_yearly_1500 => Intl.message(
        'pagando anualmente \$ 1500 y cargos adicionales de',
        name: 'plan_yearly_1500',
      );

  String get plan_details_quota1 => Intl.message(
        'por transacción facturada mensualmente al exceder la cuota mensual gratuita',
        name: 'plan_details_quota1',
      );

  String get paying => Intl.message(
        'paying',
        name: 'paying',
      );

  String get charges_of => Intl.message(
        'cargos anuales y adicionales de',
        name: 'charges_of',
      );

  String get per_transaction_quota => Intl.message(
        'per transaction billed annualy upon exceeding free monthly quota',
        name: 'per_transaction_quota',
      );

  String get status => Intl.message(
        'Estado',
        name: 'status',
      );

  String get view_selected_plans => Intl.message(
        'Ver planes seleccionados',
        name: 'view_selected_plans',
      );

  String get monthly_subscription => Intl.message(
        'Suscripciones mensuales',
        name: 'monthly_subscription',
      );

  String subscription(num count) => Intl.message(
        '${Intl.plural(count, one: '${Intl.plural(count, one: 'Suscripción', other: 'Suscripciones', args: [count])}', args: [count])}',
        name: 'subscription',        
        args: [count],
      );

  String get card_details => Intl.message(
        'DETALLES DE TARJETA',
        name: 'card_details',
      );

  String get add_new => Intl.message(
        'Agregar nuevo',
        name: 'add_new',
      );

  String get no_cards_available => Intl.message(
        'No hay tarjetas disponibles',
        name: 'no_cards_available',
      );

  String get default_card_note => Intl.message(
        'Nota: mantenga presionado para establecer una tarjeta por defecto',
        name: 'default_card_note',
      );

  String get bank_name => Intl.message(
        'Nombre del banco',
        name: 'bank_name',
      );

  String get default_card => Intl.message(
        'Tarjeta predeterminada',
        name: 'default_card',
      );

  String get already_default_card => Intl.message(
        'Esta tarjeta ya está agregada como tarjeta predeterminada',
        name: 'already_default_card',
      );

  String get make_default_card => Intl.message(
        'Hacer esta tarjeta como predeterminada',
        name: 'make_default_card',
      );

  String get card_added => Intl.message(
        'Tarjeta agregada',
        name: 'card_added',
      );

  String get card_sync => Intl.message(
        'La sincronización de su pago puede demorar un par de minutos',
        name: 'card_sync',
      );

  String get select_group => Intl.message(
        'Selecciona grupo',
        name: 'select_group',
      );

  String get delete_feed => Intl.message(
        'Eliminar feed',
        name: 'delete_feed',
      );

  String get deleting_feed => Intl.message(
        'Eliminando feed ...',
        name: 'deleting_feed',
      );

  String get delete_feed_confirmation => Intl.message(
        '¿Está seguro de que desea eliminar este servicio de noticias?',
        name: 'delete_feed_confirmation',
      );

  String get create_feed => Intl.message(
        'Crear publicación',
        name: 'create_feed',
      );

  String get create_feed_hint => Intl.message(
        'Texto, URL y hashtags',
        name: 'create_feed_hint',
      );

  String get create_feed_placeholder => Intl.message(
        'Qué te gustaría compartir*',
        name: 'create_feed_placeholder',
      );

  String get creating_feed => Intl.message(
        'Creando publicación',
        name: 'creating_feed',
      );

  String get location_not_added => Intl.message(
        'Ubicación no agregada',
        name: 'location_not_added',
      );

  String get category => Intl.message(
        'Categoría',
        name: 'category',
      );

  String get select_category => Intl.message(
        'Porfavor seleccione una categoría',
        name: 'select_category',
      );

  String get photo_credits => Intl.message(
        'Créditos fotográficos',
        name: 'photo_credits',
      );

  String get change_image => Intl.message(
        'Cambiar imagen',
        name: 'change_image',
      );

  String get change_attachment => Intl.message(
        'Cambiar adjunto',
        name: 'change_attachment',
      );

  String get add_image => Intl.message(
        'Añadir imagen',
        name: 'add_image',
      );

  String get add_attachment => Intl.message(
        'Add Image / Document',
        name: 'add_attachment',
      );

  String get validation_error_file_size => Intl.message(
        'No se permiten archivos de más de 10 MB',
        name: 'validation_error_file_size',
      );

  String get large_file_size => Intl.message(
        'Alerta de archivo grande',
        name: 'large_file_size',
      );

  String get update_feed => Intl.message(
        'Update post',
        name: 'update_feed',
      );

  String get updating_feed => Intl.message(
        'Actualizando publicación',
        name: 'updating_feed',
      );

  String get notification_alerts => Intl.message(
        'Alertas de notificación',
        name: 'notification_alerts',
      );

  String get request_accepted => Intl.message(
        'El miembro ha aceptado una solicitud y está esperando su aprobación.',
        name: 'request_accepted',
      );

  String get request_completed => Intl.message(
        'El miembro reclama créditos de tiempo y está esperando aprobación',
        name: 'request_completed',
      );

  String get join_request_message => Intl.message(
        'Solicitud de miembro para unirse a un',
        name: 'join_request_message',
      );

  String get offer_debit => Intl.message(
        'Débito por oferta de uno a muchos',
        name: 'offer_debit',
      );

  String get member_exits => Intl.message(
        'El miembro sale de un',
        name: 'member_exits',
      );

  String get deletion_request_message => Intl.message(
        'No se pudo procesar la solicitud de eliminación (debido a transacciones pendientes)',
        name: 'deletion_request_message',
      );

  String get recieved_credits_one_to_many => Intl.message(
        'Crédito recibido por la oferta de uno a muchos',
        name: 'recieved_credits_one_to_many',
      );

  String get click_to_see_interests => Intl.message(
        'Haga clic aquí para ver sus intereses',
        name: 'click_to_see_interests',
      );

  String get click_to_see_skills => Intl.message(
        'Haga clic aquí para ver sus habilidades',
        name: 'click_to_see_skills',
      );

  String get my_language => Intl.message(
        'Mi idioma',
        name: 'my_language',
      );

  String get my_timezone => Intl.message(
        'My Timezone',
        name: 'my_timezone',
      );

  String get select_timebank => Intl.message(
        'Seleccionar banco de tiempo',
        name: 'select_timebank',
      );

  String get name => Intl.message(
        'Nombre',
        name: 'name',
      );

  String get add_bio => Intl.message(
        'Agrega tu biografía',
        name: 'add_bio',
      );

  String get enter_name => Intl.message(
        'Ingrese su nombre',
        name: 'enter_name',
      );

  String get update_name => Intl.message(
        'Actualizar nombre',
        name: 'update_name',
      );

  String get enter_name_hint => Intl.message(
        'Please enter name to update',
        name: 'enter_name_hint',
      );

  String get update_bio => Intl.message(
        'Actualizar biografía',
        name: 'update_bio',
      );

  String get update_bio_hint => Intl.message(
        'Ingresa la biografía para actualizar',
        name: 'update_bio_hint',
      );

  String get enter_bio => Intl.message(
        'Ingrese bio',
        name: 'enter_bio',
      );

  String get available_as_needed => Intl.message(
        'Available as needed - Open to Offers',
        name: 'available_as_needed',
      );

  String get would_be_unblocked => Intl.message(
        'sería desbloqueado',
        name: 'would_be_unblocked',
      );

  String get jobs => Intl.message(
        'Jobs',
        name: 'jobs',
      );

  String get hours_worked => Intl.message(
        'Horas trabajadas',
        name: 'hours_worked',
      );

  String get less => Intl.message(
        'Menos',
        name: 'less',
      );

  String get more => Intl.message(
        'Más',
        name: 'more',
      );

  String get no_ratings_yet => Intl.message(
        'No ratings yet',
        name: 'no_ratings_yet',
      );

  String get message => Intl.message(
        'Message',
        name: 'message',
      );

  String get not_completed_any_tasks => Intl.message(
        'not completed any tasks',
        name: 'not_completed_any_tasks',
      );

  String get review_earnings => Intl.message(
        'Revisar ganancias',
        name: 'review_earnings',
      );

  String get no_transactions_yet => Intl.message(
        'Aún no tienes ninguna transacción',
        name: 'no_transactions_yet',
      );

  String get anonymous => Intl.message(
        'Anónimo',
        name: 'anonymous',
      );

  String get date => Intl.message(
        'Date',
        name: 'date',
      );

  String get search_template_hint => Intl.message(
        'Ingrese el nombre de una plantilla de proyecto',
        name: 'search_template_hint',
      );

  String get create_project_from_template => Intl.message(
        'Crear proyecto a partir de plantilla',
        name: 'create_project_from_template',
      );

  String get create_new_project => Intl.message(
        'Create new Project',
        name: 'create_new_project',
      );

  String get no_templates_found => Intl.message(
        'No se encontraron plantillas',
        name: 'no_templates_found',
      );

  String get select_template => Intl.message(
        'Seleccione una plantilla de la lista de plantillas disponibles',
        name: 'select_template',
      );

  String get template_alert => Intl.message(
        'Alerta de plantilla',
        name: 'template_alert',
      );

  String get new_project => Intl.message(
        'Nuevo proyecto',
        name: 'new_project',
      );

  String get review_feedback_message => Intl.message(
        'Tómese un momento para reflexionar sobre su experiencia y comparta su agradecimiento escribiendo una breve reseña.',
        name: 'review_feedback_message',
      );

  String get submit => Intl.message(
        'Enviar',
        name: 'submit',
      );

  String get review => Intl.message(
        'revisión',
        name: 'review',
      );

  String get redirecting_to_messages => Intl.message(
        'Redirigir a mensajes',
        name: 'redirecting_to_messages',
      );

  String get completing_task => Intl.message(
        'Completando tarea',
        name: 'completing_task',
      );

  String get total_spent => Intl.message(
        'Total Spent',
        name: 'total_spent',
      );

  String get has_worked_for => Intl.message(
        'ha trabajado para',
        name: 'has_worked_for',
      );

  String get email_not_updated => Intl.message(
        'Correo electrónico del usuario no actualizado',
        name: 'email_not_updated',
      );

  String get no_pending_requests => Intl.message(
        'Sin solicitudes pendientes',
        name: 'no_pending_requests',
      );

  String get choose_suitable_plan => Intl.message(
        'Elija un plan adecuado',
        name: 'choose_suitable_plan',
      );

  String get click_for_more_info => Intl.message(
        'Haga clic aquí para más información',
        name: 'click_for_more_info',
      );

  String get taking_to_new_timebank => Intl.message(
        'Llevándote a tu nuevo banco de tiempo ...',
        name: 'taking_to_new_timebank',
      );

  String get bill_me => Intl.message(
        'Cobrame',
        name: 'bill_me',
      );

  String get bill_me_info1 => Intl.message(
        'Esto está disponible solo para usuarios que hayan tenido acuerdos previos con Seva Exchange. Envíe un correo electrónico a billme@sevaexchange.com para obtener más detalles',
        name: 'bill_me_info1',
      );

  String get bill_me_info2 => Intl.message(
        'Solo los usuarios que hayan sido aprobados a priori pueden marcar la casilla \"Facturarme\". Si desea hacer esto, envíe un correo electrónico a billme@sevaexchange.com',
        name: 'bill_me_info2',
      );

  String get billable_transactions => Intl.message(
        'Transacciones facturables',
        name: 'billable_transactions',
      );

  String get currently_active => Intl.message(
        'Actualmente activo',
        name: 'currently_active',
      );

  String get choose => Intl.message(
        'Choose',
        name: 'choose',
      );

  String get plan_change => Intl.message(
        'Cambio de plan',
        name: 'plan_change',
      );

  String get ownership_success => Intl.message(
        '¡Felicidades! Ahora eres el nuevo propietario del Timebank',
        name: 'ownership_success',
      );

  String get change => Intl.message(
        'Change',
        name: 'change',
      );

  String get contact_seva_to_change_plan => Intl.message(
        'Póngase en contacto con el soporte de SevaX para cambiar los planes',
        name: 'contact_seva_to_change_plan',
      );

  String get changing_ownership_of => Intl.message(
        'Cambiar la propiedad de este',
        name: 'changing_ownership_of',
      );

  String get to_other_admin => Intl.message(
        'a otro administrador.',
        name: 'to_other_admin',
      );

  String get change_to => Intl.message(
        'Change to',
        name: 'change_to',
      );

  String get invitation_sent1 => Intl.message(
        'We have sent your transfer of ownership invitation. You will remain to be the owner of Timebank',
        name: 'invitation_sent1',
      );

  String get invitation_sent2 => Intl.message(
        'hasta',
        name: 'invitation_sent2',
      );

  String get invitation_sent3 => Intl.message(
        'acepta la invitación y proporciona su nueva información de facturación.',
        name: 'invitation_sent3',
      );

  String get by_accepting_owner_timebank => Intl.message(
        'Al aceptar, te convertirás en propietario del banco de tiempo.',
        name: 'by_accepting_owner_timebank',
      );

  String get select_user => Intl.message(
        'Por favor seleccione un usuario',
        name: 'select_user',
      );

  String get change_ownership_pending_task_message => Intl.message(
        'Tienes tareas pendientes. Complete las tareas antes de que se pueda transferir la propiedad',
        name: 'change_ownership_pending_task_message',
      );

  String get change_ownership_pending_payment1 => Intl.message(
        'You have payment pending of',
        name: 'change_ownership_pending_payment1',
      );

  String get change_ownership_pending_payment2 => Intl.message(
        '. Complete estos pagos antes de que se pueda transferir la propiedad',
        name: 'change_ownership_pending_payment2',
      );

  String get search_admin => Intl.message(
        'Search Admin',
        name: 'search_admin',
      );

  String get change_ownership_message1 => Intl.message(
        'Eres el nuevo propietario de Timebank',
        name: 'change_ownership_message1',
      );

  String get change_ownership_message2 => Intl.message(
        'Debes aceptarlo para completar el proceso.',
        name: 'change_ownership_message2',
      );

  String get change_ownership_advisory => Intl.message(
        'Debe proporcionar los detalles de facturación de este banco de tiempo, incluida la nueva dirección de facturación. La transferencia de propiedad no se completará hasta que esto se haga.',
        name: 'change_ownership_advisory',
      );

  String get change_ownership_already_invited => Intl.message(
        'ya invitado.',
        name: 'change_ownership_already_invited',
      );

  String get donate => Intl.message(
        'Donar',
        name: 'donate',
      );

  String get donate_to_timebank => Intl.message(
        'Dona créditos seva a Timebank',
        name: 'donate_to_timebank',
      );

  String get insufficient_credits_to_donate => Intl.message(
        'You do not have sufficient credits to donate!',
        name: 'insufficient_credits_to_donate',
      );

  String get current_seva_credit => Intl.message(
        'Tus créditos seva actuales son',
        name: 'current_seva_credit',
      );

  String get donate_message => Intl.message(
        'Al hacer clic en donar, se ajustará su saldo',
        name: 'donate_message',
      );

  String get zero_credit_donation_error => Intl.message(
        'No puedes donar 0 créditos',
        name: 'zero_credit_donation_error',
      );

  String get negative_credit_donation_error => Intl.message(
        'No puedes donar menos de 0 créditos',
        name: 'negative_credit_donation_error',
      );

  String get empty_credit_donation_error => Intl.message(
        'Dona algunos créditos',
        name: 'empty_credit_donation_error',
      );

  String get number_of_seva_credit => Intl.message(
        'No de créditos seva',
        name: 'number_of_seva_credit',
      );

  String get donation_success => Intl.message(
        'Has donado créditos con éxito',
        name: 'donation_success',
      );

  String get sending_invitation => Intl.message(
        'Enviando invitación ...',
        name: 'sending_invitation',
      );

  String get ownership_transfer_error => Intl.message(
        '¡Se produjo un error! Por favor, vuelva más tarde y vuelva a intentarlo.',
        name: 'ownership_transfer_error',
      );

  String get add_members => Intl.message(
        'Añadir miembros',
        name: 'add_members',
      );

  String get group_logo => Intl.message(
        'Logotipo del grupo',
        name: 'group_logo',
      );

  String get name_your_group => Intl.message(
        'Nombra tu grupo',
        name: 'name_your_group',
      );

  String get bit_more_about_group => Intl.message(
        'Ej: un poco más sobre tu grupo',
        name: 'bit_more_about_group',
      );

  String get private_group => Intl.message(
        'Grupo privado',
        name: 'private_group',
      );

  String get is_pin_at_right_place => Intl.message(
        '¿Está este pin en el lugar correcto?',
        name: 'is_pin_at_right_place',
      );

  String get find_timebanks => Intl.message(
        'Find Timebanks',
        name: 'find_timebanks',
      );

  String get groups_within => Intl.message(
        'Grupos dentro',
        name: 'groups_within',
      );

  String get edit_group => Intl.message(
        'Editar grupo',
        name: 'edit_group',
      );

  String get view_requests => Intl.message(
        'Ver solicitudes',
        name: 'view_requests',
      );

  String get delete_group => Intl.message(
        'Eliminar grupo',
        name: 'delete_group',
      );

  String get settings => Intl.message(
        'Configuraciones',
        name: 'settings',
      );

  String get invite_members => Intl.message(
        'Invitar a los miembros',
        name: 'invite_members',
      );

  String get invite_via_code => Intl.message(
        'Invitar mediante código',
        name: 'invite_via_code',
      );

  String get bulk_invite_users_csv => Intl.message(
        'Invitación masiva de usuarios mediante CSV',
        name: 'bulk_invite_users_csv',
      );

  String get csv_message1 => Intl.message(
        'Descargue la plantilla CSV para',
        name: 'csv_message1',
      );

  String get csv_message2 => Intl.message(
        'complete los usuarios que le gustaría agregar',
        name: 'csv_message2',
      );

  String get csv_message3 => Intl.message(
        'luego cargue el CSV.',
        name: 'csv_message3',
      );

  String get download_sample_csv => Intl.message(
        'Descargar archivo CSV de muestra',
        name: 'download_sample_csv',
      );

  String get choose_csv => Intl.message(
        'Choose CSV file to bulk invite Members',
        name: 'choose_csv',
      );

  String get csv_size_limit => Intl.message(
        'NOTA: el tamaño máximo del archivo es 1 MB',
        name: 'csv_size_limit',
      );

  String get uploading_csv => Intl.message(
        'Subiendo archivo CSV',
        name: 'uploading_csv',
      );

  String get uploaded_successfully => Intl.message(
        'Subido con éxito',
        name: 'uploaded_successfully',
      );

  String get csv_error => Intl.message(
        'Seleccione un archivo CSV antes de cargarlo',
        name: 'csv_error',
      );

  String get upload => Intl.message(
        'Subir',
        name: 'upload',
      );

  String get large_file_alert => Intl.message(
        'Alerta de archivo grande',
        name: 'large_file_alert',
      );

  String get csv_large_file_message => Intl.message(
        'No se permiten archivos de más de 1 MB',
        name: 'csv_large_file_message',
      );

  String get not_found => Intl.message(
        'extraviado',
        name: 'not_found',
      );

  String get resend_invite => Intl.message(
        'Reenviar invitacíon',
        name: 'resend_invite',
      );

  String get add => Intl.message(
        'Añadir',
        name: 'add',
      );

  String get no_codes_generated => Intl.message(
        'Aún no se han generado códigos.',
        name: 'no_codes_generated',
      );

  String get not_yet_redeemed => Intl.message(
        'Todavía no redimido',
        name: 'not_yet_redeemed',
      );

  String get redeemed_by => Intl.message(
        'Canjeado por',
        name: 'redeemed_by',
      );

  String get timebank_code => Intl.message(
        'Código del banco de tiempo:',
        name: 'timebank_code',
      );

  String get expired => Intl.message(
        'Caducado',
        name: 'expired',
      );

  String get active => Intl.message(
        'Activo',
        name: 'active',
      );

  String get share_code => Intl.message(
        'Compartir código',
        name: 'share_code',
      );

  String get invite_message => Intl.message(
        'Los bancos de tiempo son comunidades que le permiten ser voluntario y también recibir créditos de tiempo para hacer las cosas por usted. Usa el código',
        name: 'invite_message',
      );

  String get invite_prompt => Intl.message(
        'cuando se le solicite unirse a este banco de tiempo. Descargue la aplicación desde los enlaces que se proporcionan en https://sevaexchange.page.link/sevaxapp',
        name: 'invite_prompt',
      );

  String get code_generated => Intl.message(
        'Código generado',
        name: 'code_generated',
      );

  String get is_your_code => Intl.message(
        'es tu código.',
        name: 'is_your_code',
      );

  String get publish_code => Intl.message(
        'Publicar código',
        name: 'publish_code',
      );

  String get invite_via_email => Intl.message(
        'Invitar miembros por correo electrónico',
        name: 'invite_via_email',
      );

  String get no_member_found => Intl.message(
        'Ningún miembro encontrado',
        name: 'no_member_found',
      );

  String get declined => Intl.message(
        'Rechazado',
        name: 'declined',
      );

  String get search_by_email_name => Intl.message(
        'Buscar miembros por correo electrónico, nombre',
        name: 'search_by_email_name',
      );

  String get no_groups_found => Intl.message(
        'No se encontraron grupos',
        name: 'no_groups_found',
      );

  String get no_image_available => Intl.message(
        'No hay imagen disponible',
        name: 'no_image_available',
      );

  String get group_description => Intl.message(
        'Los grupos dentro de un banco de tiempo permiten actividades granulares. Puede unirse a uno de los grupos a continuación o crear su propio grupo',
        name: 'group_description',
      );

  String get updating_users => Intl.message(
        'Actualización de usuarios',
        name: 'updating_users',
      );

  String get admins_organizers => Intl.message(
        'Administradores y organizadores',
        name: 'admins_organizers',
      );

  String get enter_reason_to_exit => Intl.message(
        'Ingrese el motivo para salir',
        name: 'enter_reason_to_exit',
      );

  String get enter_reason_to_exit_hint => Intl.message(
        'Ingrese el motivo para salir',
        name: 'enter_reason_to_exit_hint',
      );

  String get member_removal_confirmation => Intl.message(
        'Estás seguro de que desea eliminar',
        name: 'member_removal_confirmation',
      );

  String get loan => Intl.message(
        'Préstamo',
        name: 'loan',
      );

  String get loan_seva_credit_to_user => Intl.message(
        'Préstamo de créditos seva al usuario',
        name: 'loan_seva_credit_to_user',
      );

  String get timebank_seva_credit => Intl.message(
        'Sus créditos seva del banco de tiempo es',
        name: 'timebank_seva_credit',
      );

  String get timebank_loan_message => Intl.message(
        'Al hacer clic en Aprobar, se ajustará el saldo del banco de tiempo',
        name: 'timebank_loan_message',
      );

  String get loan_zero_credit_error => Intl.message(
        'No puedes prestar 0 créditos',
        name: 'loan_zero_credit_error',
      );

  String get negative_credit_loan_error => Intl.message(
        'No puedes prestar menos de 0 créditos',
        name: 'negative_credit_loan_error',
      );

  String get empty_credit_loan_error => Intl.message(
        'Loan some credits',
        name: 'empty_credit_loan_error',
      );

  String get loan_success => Intl.message(
        'You have loaned credits successfully',
        name: 'loan_success',
      );

  String get co_ordinators => Intl.message(
        'Coordinadores',
        name: 'co_ordinators',
      );

  String get remove => Intl.message(
        'Eliminar',
        name: 'remove',
      );

  String get promote => Intl.message(
        'Promote',
        name: 'promote',
      );

  String get demote => Intl.message(
        'Degradar',
        name: 'demote',
      );

  String get billing => Intl.message(
        'Billing',
        name: 'billing',
      );

  String get edit_timebank => Intl.message(
        'Editar banco de tiempo',
        name: 'edit_timebank',
      );

  String get delete_timebank => Intl.message(
        'Eliminar banco de tiempo',
        name: 'delete_timebank',
      );

  String get remove_user => Intl.message(
        'Remove User',
        name: 'remove_user',
      );

  String get exit_user => Intl.message(
        'Salir de usuario',
        name: 'exit_user',
      );

  String get transfer_data_hint => Intl.message(
        'Transferir la propiedad de los datos de este usuario a otro usuario, como la propiedad del grupo.',
        name: 'transfer_data_hint',
      );

  String get transfer_to => Intl.message(
        'Transferir a',
        name: 'transfer_to',
      );

  String get search_user => Intl.message(
        'Buscar un usuario',
        name: 'search_user',
      );

  String get transer_hint_data_deletion => Intl.message(
        'Todos los datos no transferidos serán eliminados.',
        name: 'transer_hint_data_deletion',
      );

  String get user_removal_success => Intl.message(
        'User is successfully removed from the timebank',
        name: 'user_removal_success',
      );

  String get error_occured => Intl.message(
        '¡Se produjo un error! Por favor, vuelva más tarde y vuelva a intentarlo.',
        name: 'error_occured',
      );

  String get create_group => Intl.message(
        'Crea un grupo',
        name: 'create_group',
      );

  String get group_exists => Intl.message(
        'El nombre del grupo ya existe',
        name: 'group_exists',
      );

  String get group_subset => Intl.message(
        'Group is a subset of a Timebank that may be temporary. Ex: committees, project teams.',
        name: 'group_subset',
      );

  String get part_of => Intl.message(
        'Parte de',
        name: 'part_of',
      );

  String get global_timebank => Intl.message(
        'SevaX Global Network of Timebanks',
        name: 'global_timebank',
      );

  String get getting_volunteers => Intl.message(
        'Getting volunteers...',
        name: 'getting_volunteers',
      );

  String get no_volunteers_yet => Intl.message(
        'Aún no se ha unido ningún voluntario.',
        name: 'no_volunteers_yet',
      );

  String get read_less => Intl.message(
        'Leer menos',
        name: 'read_less',
      );

  String get read_more => Intl.message(
        'Lee mas',
        name: 'read_more',
      );

  String get admin_not_available => Intl.message(
        'Administrador no disponible',
        name: 'admin_not_available',
      );

  String get admin_cannot_create_message => Intl.message(
        'Los administradores no pueden crear mensajes',
        name: 'admin_cannot_create_message',
      );

  String get volunteers => Intl.message(
        'Voluntario (s)',
        name: 'volunteers',
      );

  String get and_others => Intl.message(
        'y otros',
        name: 'and_others',
      );

  String get admins => Intl.message(
        'Administradores',
        name: 'admins',
      );

  String get remove_as_admin => Intl.message(
        'Remove as admin',
        name: 'remove_as_admin',
      );

  String get add_as_admin => Intl.message(
        'Agregar como administrador',
        name: 'add_as_admin',
      );

  String get view_profile => Intl.message(
        'Ver perfil',
        name: 'view_profile',
      );

  String get remove_member => Intl.message(
        'Remove member',
        name: 'remove_member',
      );

  String get from_timebank_members => Intl.message(
        'de los miembros de Timebank?',
        name: 'from_timebank_members',
      );

  String get no_volunteers_available => Intl.message(
        'No hay voluntarios disponibles',
        name: 'no_volunteers_available',
      );

  String get select_volunteer => Intl.message(
        'Seleccionar voluntarios',
        name: 'select_volunteer',
      );

  String get no_requests => Intl.message(
        'Sin solicitudes',
        name: 'no_requests',
      );

  String get switching_timebank => Intl.message(
        'Cambio de banco de tiempo',
        name: 'switching_timebank',
      );

  String get tap_to_delete => Intl.message(
        'Tap to delete this item',
        name: 'tap_to_delete',
      );

  String get clear => Intl.message(
        'Claro',
        name: 'clear',
      );

  String get currently_selected => Intl.message(
        'Actualmente seleccionado',
        name: 'currently_selected',
      );

  String get tap_to_remove_tooltip => Intl.message(
        'elementos (toque para eliminar)',
        name: 'tap_to_remove_tooltip',
      );

  String get timebank_exit => Intl.message(
        'Timebank Exit',
        name: 'timebank_exit',
      );

  String get has_exited_from => Intl.message(
        'ha salido de',
        name: 'has_exited_from',
      );

  String get tap_to_view_details => Intl.message(
        'Toque para ver los detalles',
        name: 'tap_to_view_details',
      );

  String get invited_to_timebank_message => Intl.message(
        '¡Increíble! Estás invitado a unirte a un banco de tiempo',
        name: 'invited_to_timebank_message',
      );

  String get invitation_email_body => Intl.message(
        '',
        name: 'invitation_email_body',
      );

  String get open_settings => Intl.message(
        'Open Settings',
        name: 'open_settings',
      );

  String get failed_to_fetch_location => Intl.message(
        'Failed to fetch location',
        name: 'failed_to_fetch_location',
      );

  String get marker => Intl.message(
        'Marker',
        name: 'marker',
      );

  String get missing_permission => Intl.message(
        'Permiso faltante',
        name: 'missing_permission',
      );

  String get pdf_document => Intl.message(
        'Documento PDF',
        name: 'pdf_document',
      );
}

class ArbifyLocalizationsDelegate extends LocalizationsDelegate<S> {
  const ArbifyLocalizationsDelegate();

  List<Locale> get supportedLocales => [
        Locale.fromSubtags(languageCode: 'es'),
        Locale.fromSubtags(languageCode: 'pt'),
        Locale.fromSubtags(languageCode: 'zh'),
        Locale.fromSubtags(languageCode: 'en'),
        Locale.fromSubtags(languageCode: 'fr'),
  ];

  @override
  bool isSupported(Locale locale) => [
        'es',
        'pt',
        'zh',
        'en',
        'fr',
      ].contains(locale.languageCode);

  @override
  Future<S> load(Locale locale) => S.load(locale);

  @override
  bool shouldReload(ArbifyLocalizationsDelegate old) => false;
}
