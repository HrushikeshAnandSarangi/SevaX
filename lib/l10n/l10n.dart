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
        'Verificando, se nos conhecemos antes',
        name: 'check_met',
      );

  String get we_met => Intl.message(
        'Nós nos encontramos antes',
        name: 'we_met',
      );

  String get hang_on => Intl.message(
        'Aguarde',
        name: 'hang_on',
      );

  String get skills => Intl.message(
        'Habilidades',
        name: 'skills',
      );

  String get interests => Intl.message(
        'Interesses',
        name: 'interests',
      );

  String get email => Intl.message(
        'Correo electrónico',
        name: 'email',
      );

  String get password => Intl.message(
        'Contraseña',
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
        'Administraremos la información como se describe en nuestra',
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
        '¿Nuevo Usuario?',
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
        '¿Se te olvidó tu contraseña?',
        name: 'forgot_password',
      );

  String get reset => Intl.message(
        ' Reiniciar',
        name: 'reset',
      );

  String get sign_in_with_google => Intl.message(
        'Inicia sesión con Google',
        name: 'sign_in_with_google',
      );

  String get sign_in_with_apple => Intl.message(
        'Inicia sesión con Apple',
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
        'Dispensar',
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
        'La contraseña debe tener 6 caracteres.',
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
        'Por favor revise su correo electrónico para configurar su contraseña. Luego ingrese esa contraseña aquí',
        name: 'reset_dynamic_link_message',
      );

  String get close => Intl.message(
        'Fechar',
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
        'Saltar y registrarse',
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
        'Câmera',
        name: 'camera',
      );

  String get gallery => Intl.message(
        'Galeria',
        name: 'gallery',
      );

  String get email_sent_to => Intl.message(
        '\\ n \\ nEnviamos un correo electrónico a \\ n',
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
        'El correo electrónico de verificación se envió a su correo electrónico registrado',
        name: 'verification_sent_desc',
      );

  String get log_in => Intl.message(
        'Iniciar sesión',
        name: 'log_in',
      );

  String get eula_title => Intl.message(
        'Acuerdo de EULA',
        name: 'eula_title',
      );

  String get eula_delcaration => Intl.message(
        'Acepto que estaré dispuesto a estar sujeto a estos términos y condiciones.',
        name: 'eula_delcaration',
      );

  String get proceed => Intl.message(
        'Continuar',
        name: 'proceed',
      );

  String get skills_description => Intl.message(
        '¿En qué habilidades eres bueno y que te gustaría compartir con tu comunidad?',
        name: 'skills_description',
      );

  String get no_matching_skills => Intl.message(
        'No se encontraron habilidades de emparejamiento',
        name: 'no_matching_skills',
      );

  String get search => Intl.message(
        'Procurar',
        name: 'search',
      );

  String get update => Intl.message(
        'Atualizar',
        name: 'update',
      );

  String get next => Intl.message(
        'Próximo',
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
        'Biografia',
        name: 'bio',
      );

  String get bio_description => Intl.message(
        'Cuéntanos un poco sobre ti en unas pocas oraciones. Por ejemplo, lo que te hace único.',
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
        '* min 50 caracteres',
        name: 'validation_error_bio_min_characters',
      );

  String get join => Intl.message(
        'Unirse',
        name: 'join',
      );

  String get joined => Intl.message(
        'Ingressou',
        name: 'joined',
      );

  String get timebanks_near_you => Intl.message(
        'Timebanks cerca de ti',
        name: 'timebanks_near_you',
      );

  String get find_your_timebank => Intl.message(
        'Encuentra tu banco del tiempo',
        name: 'find_your_timebank',
      );

  String get looking_existing_timebank => Intl.message(
        'Buscando un banco de tiempo existente para unirse',
        name: 'looking_existing_timebank',
      );

  String get find_timebank_help_text => Intl.message(
        'Escriba el nombre de su banco de tiempo. Ej: Alaska (min 1 char)',
        name: 'find_timebank_help_text',
      );

  String get no_timebanks_found => Intl.message(
        'No se encontraron bancos de tiempo',
        name: 'no_timebanks_found',
      );

  String get timebank => Intl.message(
        'Timebank',
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
        'Asegúrate de tener el GPS activado. ver la lista de bancos de tiempo a tu alrededor',
        name: 'timebank_gps_hint',
      );

  String get create_timebank_confirmation => Intl.message(
        '¿Está seguro de que desea crear un nuevo Banco de tiempo, en lugar de unirse a un Banco de tiempo existente? La creación de un nuevo Banco de tiempo implica que usted será responsable de administrar el Banco de tiempo, lo que incluye agregar miembros y administrar las necesidades de los miembros, responder oportunamente a las preguntas de los miembros, generar resoluciones de conflictos y organizar comidas compartidas mensuales. Para convertirse en miembro de un banco de tiempo existente, deberá conocer el nombre del banco de tiempo y tener un código de invitación o enviar una solicitud para unirse al banco de tiempo.',
        name: 'create_timebank_confirmation',
      );

  String get try_later => Intl.message(
        'Por favor, tente novamente mais tarde',
        name: 'try_later',
      );

  String get log_out => Intl.message(
        'Sair',
        name: 'log_out',
      );

  String get log_out_confirmation => Intl.message(
        'Tem certeza de que deseja sair?',
        name: 'log_out_confirmation',
      );

  String get requested => Intl.message(
        'PEDIDO',
        name: 'requested',
      );

  String get rejected => Intl.message(
        'RECHAZADO',
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
        'Usted ya solicitó este banco de tiempo. Por favor espere hasta que se acepte la solicitud',
        name: 'join_timbank_already_requested',
      );

  String get join_timebank_question => Intl.message(
        '¿Por qué quieres unirte a la',
        name: 'join_timebank_question',
      );

  String get reason => Intl.message(
        'Razón',
        name: 'reason',
      );

  String get validation_error_general_text => Intl.message(
        'Por favor, indique algum texto',
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
        'el código no se registró, verifique el código e intente nuevamente.',
        name: 'validation_error_wrong_timebank_code',
      );

  String get validation_error_join_code_expired => Intl.message(
        'Código caducado!',
        name: 'validation_error_join_code_expired',
      );

  String get join_code_expired_hint => Intl.message(
        'el código ha caducado, solicite al administrador uno nuevo.',
        name: 'join_code_expired_hint',
      );

  String get awesome => Intl.message(
        '¡Increíble!',
        name: 'awesome',
      );

  String get timebank_onboarding_message => Intl.message(
        'Has sido abordado para',
        name: 'timebank_onboarding_message',
      );

  String get successfully => Intl.message(
        'exitosamente.',
        name: 'successfully',
      );

  String get validation_error_timebank_join_code_redeemed => Intl.message(
        'Código do timebank já resgatado',
        name: 'validation_error_timebank_join_code_redeemed',
      );

  String get validation_error_timebank_join_code_redeemed_self => Intl.message(
        'O código do Timebank que você forneceu já foi resgatado anteriormente. Solicite ao administrador do Timebank um novo código.',
        name: 'validation_error_timebank_join_code_redeemed_self',
      );

  String get code_expired => Intl.message(
        'Código caducado!',
        name: 'code_expired',
      );

  String get enter_code_to_verify => Intl.message(
        'Por favor, introduzca el PIN para verificar',
        name: 'enter_code_to_verify',
      );

  String get creating_join_request => Intl.message(
        'Crear solicitud de unión',
        name: 'creating_join_request',
      );

  String get feeds => Intl.message(
        'Publicações',
        name: 'feeds',
      );

  String get projects => Intl.message(
        'Projetos',
        name: 'projects',
      );

  String get offers => Intl.message(
        'Ofertas',
        name: 'offers',
      );

  String get requests => Intl.message(
        'Solicitações de',
        name: 'requests',
      );

  String get about => Intl.message(
        'Sobre',
        name: 'about',
      );

  String get members => Intl.message(
        'Membros',
        name: 'members',
      );

  String get manage => Intl.message(
        'Gerir',
        name: 'manage',
      );

  String get your_tasks => Intl.message(
        'Tus tareas',
        name: 'your_tasks',
      );

  String get your_groups => Intl.message(
        'Sus grupos',
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
        'Acciones no permitidas, póngase en contacto con el administrador',
        name: 'actions_not_allowed',
      );

  String get configure_billing => Intl.message(
        'Configurar facturación',
        name: 'configure_billing',
      );

  String get limit_badge_contact_admin => Intl.message(
        'Acción no permitida, por favor contacte al administrador',
        name: 'limit_badge_contact_admin',
      );

  String get limit_badge_billing_failed => Intl.message(
        'Facturación fallida, haga clic a continuación para configurar la facturación',
        name: 'limit_badge_billing_failed',
      );

  String get limit_badge_delete_in_progress => Intl.message(
        'Sua solicitação para excluir foi recebida por nós. Estamos processando a solicitação. Você será notificado assim que estiver concluído.',
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
        'Casa',
        name: 'bottom_nav_home',
      );

  String get bottom_nav_messages => Intl.message(
        'Mensagens',
        name: 'bottom_nav_messages',
      );

  String get bottom_nav_profile => Intl.message(
        'Perfil',
        name: 'bottom_nav_profile',
      );

  String get ok => Intl.message(
        'Está bem',
        name: 'ok',
      );

  String get no_group_message => Intl.message(
        'Los grupos te ayudan a organizar tus \\ n actividades específicas, no tienes ninguna. Prueba',
        name: 'no_group_message',
      );

  String get creating_one => Intl.message(
        'criando um',
        name: 'creating_one',
      );

  String get general_stream_error => Intl.message(
        '¡Algo salió mal!',
        name: 'general_stream_error',
      );

  String get no_pending_task => Intl.message(
        'No hay tareas pendientes.',
        name: 'no_pending_task',
      );

  String get from => Intl.message(
        'Desde:',
        name: 'from',
      );

  String get until => Intl.message(
        ' hasta ',
        name: 'until',
      );

  String get posted_by => Intl.message(
        'Publicado por:',
        name: 'posted_by',
      );

  String get posted_date => Intl.message(
        'Posfechar:',
        name: 'posted_date',
      );

  String get enter_hours => Intl.message(
        'Ingrese horas',
        name: 'enter_hours',
      );

  String get select_hours => Intl.message(
        'Seleccione horas',
        name: 'select_hours',
      );

  String get validation_error_task_minutes => Intl.message(
        'Los minutos no pueden estar vacíos',
        name: 'validation_error_task_minutes',
      );

  String get minutes => Intl.message(
        'Minutos',
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
        'Por favor ingrese un número válido de horas!',
        name: 'validation_error_invalid_hours',
      );

  String get please_wait => Intl.message(
        'Por favor espera...',
        name: 'please_wait',
      );

  String get task_max_request_message => Intl.message(
        'Solo puede solicitar un máximo de',
        name: 'task_max_request_message',
      );

  String get there_are_currently_none => Intl.message(
        'Actualmente no hay ninguno',
        name: 'there_are_currently_none',
      );

  String get no_completed_task => Intl.message(
        'No has completado ninguna tarea',
        name: 'no_completed_task',
      );

  String get completed_tasks => Intl.message(
        'Tareas completadas',
        name: 'completed_tasks',
      );

  String get seva_credits => Intl.message(
        'Seva Credits',
        name: 'seva_credits',
      );

  String get no_notifications => Intl.message(
        'No Notificaciones',
        name: 'no_notifications',
      );

  String get personal => Intl.message(
        'Pessoal',
        name: 'personal',
      );

  String get notifications_signed_up_for => Intl.message(
        'Te habías registrado para',
        name: 'notifications_signed_up_for',
      );

  String get on => Intl.message(
        'en',
        name: 'on',
      );

  String get notifications_event_modification => Intl.message(
        '. El propietario del evento ha modificado este evento. Asegúrese de que los cambios realizados sean adecuados para usted y solicite nuevamente',
        name: 'notifications_event_modification',
      );

  String get notification_timebank_join => Intl.message(
        'Timebank Join',
        name: 'notification_timebank_join',
      );

  String get notifications_added_you => Intl.message(
        'adicionou você a',
        name: 'notifications_added_you',
      );

  String get notifications_request_rejected_by => Intl.message(
        'Solicitud rechazada por',
        name: 'notifications_request_rejected_by',
      );

  String get notifications_join_request => Intl.message(
        'Solicitud de inscripción',
        name: 'notifications_join_request',
      );

  String get notifications_requested_join => Intl.message(
        'te ha pedido que te unas',
        name: 'notifications_requested_join',
      );

  String get notifications_tap_to_view => Intl.message(
        'Toque para ver la solicitud de ingreso',
        name: 'notifications_tap_to_view',
      );

  String get notifications_task_rejected_by => Intl.message(
        'Finalización de tarea rechazada por',
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
        'ha sido acreditado a su cuenta.',
        name: 'notifications_credited_to',
      );

  String get congrats => Intl.message(
        '¡Felicidades!',
        name: 'congrats',
      );

  String get notifications_debited => Intl.message(
        'Debitado',
        name: 'notifications_debited',
      );

  String get notifications_debited_to => Intl.message(
        'ha sido cargado en su cuenta',
        name: 'notifications_debited_to',
      );

  String get notifications_offer_accepted => Intl.message(
        'Oferta aceptada',
        name: 'notifications_offer_accepted',
      );

  String get notifications_shown_interest => Intl.message(
        'ha mostrado interés en su oferta',
        name: 'notifications_shown_interest',
      );

  String get notifications_invited_to_join => Intl.message(
        'Convidou você para participar',
        name: 'notifications_invited_to_join',
      );

  String get notifications_group_join_invite => Intl.message(
        'Convite para ingresso no grupo',
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
        'Registrado para la clase',
        name: 'notifications_signed_for_class',
      );

  String get notifications_feedback_request => Intl.message(
        'Solicitud de comentarios',
        name: 'notifications_feedback_request',
      );

  String get notifications_was_deleted => Intl.message(
        'Foi apagado!',
        name: 'notifications_was_deleted',
      );

  String get notifications_could_not_delete => Intl.message(
        'Não foi possível excluir!',
        name: 'notifications_could_not_delete',
      );

  String get notifications_successfully_deleted => Intl.message(
        '*** foi excluído com sucesso.',
        name: 'notifications_successfully_deleted',
      );

  String get notifications_could_not_deleted => Intl.message(
        ' não pôde ser excluído porque você possui transações pendentes!',
        name: 'notifications_could_not_deleted',
      );

  String get notifications_incomplete_transaction => Intl.message(
        'Não foi possível processar o seu pedido de exclusão de ***, pois você ainda possui transações abertas como: \n',
        name: 'notifications_incomplete_transaction',
      );

  String get one_to_many_offers => Intl.message(
        'uma a muitas ofertas\n',
        name: 'one_to_many_offers',
      );

  String get open_requests => Intl.message(
        'pedidos abertos\n',
        name: 'open_requests',
      );

  String get delete => Intl.message(
        'Excluir',
        name: 'delete',
      );

  String get delete_notification => Intl.message(
        'Excluir notificação',
        name: 'delete_notification',
      );

  String get delete_notification_confirmation => Intl.message(
        'Tem certeza de que deseja excluir esta notificação?',
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
        'Al aprobar',
        name: 'notifications_by_approving',
      );

  String get notifications_will_be_added_to => Intl.message(
        'se agregará al evento',
        name: 'notifications_will_be_added_to',
      );

  String get approve => Intl.message(
        'Aprovar',
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
        'Comience una nueva fuente ...',
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
        'Informe de alimentación',
        name: 'report_feed',
      );

  String get report_feed_confirmation_message => Intl.message(
        '¿Quieres denunciar este feed?',
        name: 'report_feed_confirmation_message',
      );

  String get already_reported => Intl.message(
        'Ya reportado!',
        name: 'already_reported',
      );

  String get feed_reported => Intl.message(
        'Ya informaste este feed',
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
        '¿Estás seguro de que deseas eliminar esta solicitud?',
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
        'Número de voluntarios requeridos:',
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
        'No hay miembros aprobados todavía.',
        name: 'no_approved_members',
      );

  String get view_approved_members => Intl.message(
        'Ver miembros aprobados',
        name: 'view_approved_members',
      );

  String get request => Intl.message(
        'Solicitações de',
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
        'DEFECTO',
        name: 'default_text',
      );

  String get access_denied => Intl.message(
        'Acesso negado.',
        name: 'access_denied',
      );

  String get not_authorized_create_request => Intl.message(
        'Você não está autorizado a criar uma solicitação..',
        name: 'not_authorized_create_request',
      );

  String get add_requests => Intl.message(
        'Adicionar solicitações',
        name: 'add_requests',
      );

  String get no_requests_available => Intl.message(
        'Não há pedidos disponíveis.Try',
        name: 'no_requests_available',
      );

  String get fetching_location => Intl.message(
        'Buscando local',
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
        'Missão',
        name: 'mission_statement',
      );

  String get organizer => Intl.message(
        'Organizador',
        name: 'organizer',
      );

  String get delete_project => Intl.message(
        'Excluir projeto',
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

  String get project_logo => Intl.message(
        'Logotipo del proyecto',
        name: 'project_logo',
      );

  String get project_name => Intl.message(
        'Nombre del proyecto',
        name: 'project_name',
      );

  String get name_hint => Intl.message(
        'Ex: Animais de estimação na cidade, Citizen collab',
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
        'Ej: un poco más sobre su proyecto que ayudará a asociarse con',
        name: 'project_mission_statement_hint',
      );

  String get validation_error_mission_empty => Intl.message(
        'La declaración de misión no puede estar vacía.',
        name: 'validation_error_mission_empty',
      );

  String get email_hint => Intl.message(
        'ejemplo@ejemplo.com',
        name: 'email_hint',
      );

  String get phone_number => Intl.message(
        'Número de teléfono',
        name: 'phone_number',
      );

  String get project_location => Intl.message(
        'La ubicación de tu proyecto.',
        name: 'project_location',
      );

  String get project_location_hint => Intl.message(
        'La ubicación del proyecto ayudará a sus miembros a localizar',
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
        'Por favor agregue ubicación a su proyecto',
        name: 'validation_error_add_project_location',
      );

  String get updating_project => Intl.message(
        'Proyecto de actualización',
        name: 'updating_project',
      );

  String get save => Intl.message(
        'Salvar',
        name: 'save',
      );

  String get template_title => Intl.message(
        'Proporcione un nombre único para la plantilla.',
        name: 'template_title',
      );

  String get template_hint => Intl.message(
        'Nombre de la plantilla',
        name: 'template_hint',
      );

  String get validation_error_template_name => Intl.message(
        'El nombre de la plantilla no puede estar vacío.',
        name: 'validation_error_template_name',
      );

  String get validation_error_template_name_exists => Intl.message(
        'El nombre de la plantilla ya está en uso.\nPor favor proporcione otro nombre.',
        name: 'validation_error_template_name_exists',
      );

  String get add_location => Intl.message(
        'Añade una ubicación',
        name: 'add_location',
      );

  String get delete_confirmation => Intl.message(
        'Tem certeza de que deseja excluir',
        name: 'delete_confirmation',
      );

  String get accidental_delete_enabled => Intl.message(
        'Exclusão acidental ativada',
        name: 'accidental_delete_enabled',
      );

  String get accidental_delete_enabled_description => Intl.message(
        'Este ** tem \"Impedir exclusão acidental \" ativado. Por favor, desmarque essa caixa (na guia \"Gerenciar \") antes de tentar excluir o **.',
        name: 'accidental_delete_enabled_description',
      );

  String get deletion_request_being_processed => Intl.message(
        'Sua solicitação de exclusão está sendo processada.',
        name: 'deletion_request_being_processed',
      );

  String get deletion_request_progress_description => Intl.message(
        'Sua solicitação para excluir foi recebida por nós. Estamos processando a solicitação. Você será notificado assim que estiver concluído.',
        name: 'deletion_request_progress_description',
      );

  String get submitting_request => Intl.message(
        'Enviando solicitação ...',
        name: 'submitting_request',
      );

  String get advisory_for_timebank => Intl.message(
        'Todas as informações relevantes, incluindo projetos, solicitações e ofertas do grupo, serão excluídas!',
        name: 'advisory_for_timebank',
      );

  String get advisory_for_projects => Intl.message(
        'Todas as solicitações associadas a essa solicitação seriam removidas',
        name: 'advisory_for_projects',
      );

  String get deletion_request_recieved => Intl.message(
        'Recebemos sua solicitação para excluir este ***. Lamentamos vê-lo partir. Examinaremos sua solicitação e (em alguns casos) entraremos em contato com você off-line antes de processarmos a exclusão do ***',
        name: 'deletion_request_recieved',
      );

  String get request_submitted => Intl.message(
        'Solicitação Enviada',
        name: 'request_submitted',
      );

  String get request_failed => Intl.message(
        'Pedido falhou!',
        name: 'request_failed',
      );

  String get request_failure_message => Intl.message(
        'A solicitação de envio falhou de alguma forma. Tente novamente mais tarde!',
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
        'Has solicitado la solicitud.',
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
        'No puede retirar la solicitud ya que ya está aprobada',
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
        'Pasado contratado',
        name: 'past_hired',
      );

  String get type_team_member_name => Intl.message(
        'Escriba el nombre de los miembros de su equipo',
        name: 'type_team_member_name',
      );

  String get validation_error_search_min_characters => Intl.message(
        'A pesquisa requer no mínimo 3 caracteres',
        name: 'validation_error_search_min_characters',
      );

  String get no_user_found => Intl.message(
        'Nenhum usuário encontrado',
        name: 'no_user_found',
      );

  String get approved => Intl.message(
        'Aprobado',
        name: 'approved',
      );

  String get invite => Intl.message(
        'Convite',
        name: 'invite',
      );

  String get name_not_available => Intl.message(
        'Nombre no disponible',
        name: 'name_not_available',
      );

  String get create_request => Intl.message(
        'Crear solicitud',
        name: 'create_request',
      );

  String get create_project_request => Intl.message(
        'Criar solicitação de projeto',
        name: 'create_project_request',
      );

  String get set_duration => Intl.message(
        'Clique para definir a duração',
        name: 'set_duration',
      );

  String get request_title => Intl.message(
        'Título da solicitação *',
        name: 'request_title',
      );

  String get request_title_hint => Intl.message(
        'Ex: pequenos trabalhos de carpintaria ...',
        name: 'request_title_hint',
      );

  String get request_subject => Intl.message(
        'Digite o assunto da sua solicitação',
        name: 'request_subject',
      );

  String get request_duration => Intl.message(
        'Duração da solicitação',
        name: 'request_duration',
      );

  String get request_description => Intl.message(
        'Solicitar descrição *',
        name: 'request_description',
      );

  String get request_description_hint => Intl.message(
        'Sua solicitação e qualquer #hashtags',
        name: 'request_description_hint',
      );

  String get number_of_volunteers => Intl.message(
        'Nº de voluntários *',
        name: 'number_of_volunteers',
      );

  String get validation_error_volunteer_count => Intl.message(
        'Digite o número de voluntários necessários',
        name: 'validation_error_volunteer_count',
      );

  String get validation_error_volunteer_count_negative => Intl.message(
        'O número de voluntários não pode ser menor que 0',
        name: 'validation_error_volunteer_count_negative',
      );

  String get validation_error_volunteer_count_zero => Intl.message(
        'O número de voluntários não pode ser 0',
        name: 'validation_error_volunteer_count_zero',
      );

  String get validation_error_same_start_date_end_date => Intl.message(
        'Ha proporcionado una fecha y hora idénticas para el inicio y el final. Proporcione una hora de finalización posterior a la hora de inicio.',
        name: 'validation_error_same_start_date_end_date',
      );

  String get validation_error_empty_recurring_days => Intl.message(
        'los días recurrentes no pueden estar vacíos',
        name: 'validation_error_empty_recurring_days',
      );

  String get creating_request => Intl.message(
        'Criando solicitação ..',
        name: 'creating_request',
      );

  String get updating_request => Intl.message(
        'Atualizando solicitação ..',
        name: 'updating_request',
      );

  String get insufficient_credits_for_request => Intl.message(
        'Seus créditos seva não são suficientes para criar a solicitação.',
        name: 'insufficient_credits_for_request',
      );

  String get assign_to_volunteers => Intl.message(
        'Designar para voluntários',
        name: 'assign_to_volunteers',
      );

  String get timebank_max_seva_credit_message1 => Intl.message(
        'Seva Credits se acreditará al Timebank por esta solicitud. Tenga en cuenta que cada participante recibirá un máximo de',
        name: 'timebank_max_seva_credit_message1',
      );

  String get timebank_max_seva_credit_message2 => Intl.message(
        'créditos por completar esta solicitud',
        name: 'timebank_max_seva_credit_message2',
      );

  String get personal_max_seva_credit_message1 => Intl.message(
        'Se requieren créditos Seva para esta solicitud. Se debitará de su saldo. Tenga en cuenta que cada participante recibirá un máximo de',
        name: 'personal_max_seva_credit_message1',
      );

  String get personal_max_seva_credit_message2 => Intl.message(
        'créditos por completar esta solicitud',
        name: 'personal_max_seva_credit_message2',
      );

  String get unassigned => Intl.message(
        'Não atribuído',
        name: 'unassigned',
      );

  String get assign_to_project => Intl.message(
        'Atribuir ao projeto',
        name: 'assign_to_project',
      );

  String get assign_to_one_project => Intl.message(
        'Atribua a um projeto',
        name: 'assign_to_one_project',
      );

  String get tap_to_select => Intl.message(
        'Toque para selecionar um ou mais...',
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
        'después',
        name: 'after',
      );

  String get occurences => Intl.message(
        'ocurrencias',
        name: 'occurences',
      );

  String get done => Intl.message(
        'hecho',
        name: 'done',
      );

  String get date_time => Intl.message(
        'Data e hora',
        name: 'date_time',
      );

  String get start => Intl.message(
        'Começar',
        name: 'start',
      );

  String get end => Intl.message(
        'Fim',
        name: 'end',
      );

  String get time => Intl.message(
        'Tempo',
        name: 'time',
      );

  String get date_selection_issue => Intl.message(
        'Data de seleção',
        name: 'date_selection_issue',
      );

  String get validation_error_end_date_greater => Intl.message(
        'A Data de término não pode ser anterior à Data de início',
        name: 'validation_error_end_date_greater',
      );

  String get unblock => Intl.message(
        'Desatascar',
        name: 'unblock',
      );

  String get no_blocked_members => Intl.message(
        'No hay miembros bloqueados',
        name: 'no_blocked_members',
      );

  String get blocked_members => Intl.message(
        'Miembros bloqueados',
        name: 'blocked_members',
      );

  String get confirm_location => Intl.message(
        'CONFIRMAR LOCAL',
        name: 'confirm_location',
      );

  String get no_message => Intl.message(
        'Ningún mensaje',
        name: 'no_message',
      );

  String get reject_task_completion => Intl.message(
        'Estoy rechazando su solicitud de finalización de tarea porque',
        name: 'reject_task_completion',
      );

  String get type_message => Intl.message(
        'Escribir un mensaje',
        name: 'type_message',
      );

  String get failed_to_load_post => Intl.message(
        '¡No se pudo cargar la publicación!',
        name: 'failed_to_load_post',
      );

  String get admin => Intl.message(
        'Admin',
        name: 'admin',
      );

  String get new_message_room => Intl.message(
        'Sala de mensajería nuevo multiusuario',
        name: 'new_message_room',
      );

  String get messaging_room_name => Intl.message(
        'Nombre de mensajería multi-usuario',
        name: 'messaging_room_name',
      );

  String get new_chat => Intl.message(
        'Nueva conversación',
        name: 'new_chat',
      );

  String get frequently_contacted => Intl.message(
        'contactados frecuentemente',
        name: 'frequently_contacted',
      );

  String get groups => Intl.message(
        'GRUPOS',
        name: 'groups',
      );

  String get timebank_members => Intl.message(
        'TimeBank MIEMBROS',
        name: 'timebank_members',
      );

  String get add_participants => Intl.message(
        'Añadir participantes',
        name: 'add_participants',
      );

  String get participants => Intl.message(
        'Participantes',
        name: 'participants',
      );

  String get messaging_room => Intl.message(
        'Sala de mensajería multi-usuario',
        name: 'messaging_room',
      );

  String get creating_messaging_room => Intl.message(
        'Sala de mensajería creación de múltiples usuarios ...',
        name: 'creating_messaging_room',
      );

  String get updating_messaging_room => Intl.message(
        'Sala de mensajería actualizar multiusuario ...',
        name: 'updating_messaging_room',
      );

  String get messaging_room_note => Intl.message(
        'Por favor, proporcione un nombre de usuario multi-sala de la mensajería y el icono opcional',
        name: 'messaging_room_note',
      );

  String get exit_messaging_room => Intl.message(
        'Salir de la sala de mensajería',
        name: 'exit_messaging_room',
      );

  String get exit_messaging_room_admin_confirmation => Intl.message(
        'Usted es administrador de esta sala de mensajería, ¿está seguro de que desea salir de la sala de mensajería?',
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
        'Agrega un subtítulo',
        name: 'add_caption',
      );

  String get tap_for_photo => Intl.message(
        'Toque para la foto',
        name: 'tap_for_photo',
      );

  String get validation_error_room_name => Intl.message(
        'El nombre no puede estar vacío',
        name: 'validation_error_room_name',
      );

  String get chat_block_warning => Intl.message(
        'ya no estará disponible para enviarle mensajes e interactuar con el contenido que cree',
        name: 'chat_block_warning',
      );

  String get delete_chat_confirmation => Intl.message(
        '¿Estás seguro de que deseas eliminar este chat?',
        name: 'delete_chat_confirmation',
      );

  String get block => Intl.message(
        'Bloquear',
        name: 'block',
      );

  String get exit_messaging_room_user_confirmation => Intl.message(
        '¿Está seguro de que desea salir de la sala de mensajería?',
        name: 'exit_messaging_room_user_confirmation',
      );

  String get exit => Intl.message(
        'Saída',
        name: 'exit',
      );

  String get delete_chat => Intl.message(
        'Eliminar chat',
        name: 'delete_chat',
      );

  String get group => Intl.message(
        'Grupo',
        name: 'group',
      );

  String get shared_post => Intl.message(
        'Compartió una publicación.',
        name: 'shared_post',
      );

  String get change_ownership => Intl.message(
        'Cambiar propiedad',
        name: 'change_ownership',
      );

  String get change_ownership_invite => Intl.message(
        'te ha invitado a ser el nuevo propietario del Banco de tiempo',
        name: 'change_ownership_invite',
      );

  String get notifications_insufficient_credits => Intl.message(
        'Sus créditos de seva no son suficientes para aprobar la solicitud de crédito.',
        name: 'notifications_insufficient_credits',
      );

  String get completed_task_in => Intl.message(
        'completado la tarea en',
        name: 'completed_task_in',
      );

  String get by_approving_you_accept => Intl.message(
        'Al aprobar, acepta que',
        name: 'by_approving_you_accept',
      );

  String get reject => Intl.message(
        'Rejeitar',
        name: 'reject',
      );

  String get no_comments => Intl.message(
        'Sin comentarios',
        name: 'no_comments',
      );

  String get reason_to_join => Intl.message(
        'Razón para unirse',
        name: 'reason_to_join',
      );

  String get reason_not_mentioned => Intl.message(
        'Motivo no mencionado',
        name: 'reason_not_mentioned',
      );

  String get allow => Intl.message(
        'Permitir',
        name: 'allow',
      );

  String get updating_timebank => Intl.message(
        'Actualizando el banco de tiempo.',
        name: 'updating_timebank',
      );

  String get no_bookmarked_offers => Intl.message(
        'No hay ofertas marcadas',
        name: 'no_bookmarked_offers',
      );

  String get create_offer => Intl.message(
        'Criar Oferta',
        name: 'create_offer',
      );

  String get individual_offer => Intl.message(
        'Oferta individual',
        name: 'individual_offer',
      );

  String get one_to_many => Intl.message(
        'Uno para muchos',
        name: 'one_to_many',
      );

  String get update_offer => Intl.message(
        'Oferta de atualização',
        name: 'update_offer',
      );

  String get creating_offer => Intl.message(
        'Criando Oferta',
        name: 'creating_offer',
      );

  String get updating_offer => Intl.message(
        'Atualizando oferta',
        name: 'updating_offer',
      );

  String get offer_error_creating => Intl.message(
        'Ocorreu um erro ao criar sua oferta. Tente novamente.',
        name: 'offer_error_creating',
      );

  String get offer_error_updating => Intl.message(
        'Ocorreu um erro ao atualizar a oferta. Tente novamente.',
        name: 'offer_error_updating',
      );

  String get offer_title_hint => Intl.message(
        'Ex babá',
        name: 'offer_title_hint',
      );

  String get offer_description => Intl.message(
        'Descrição da oferta',
        name: 'offer_description',
      );

  String get offer_description_hint => Intl.message(
        'Sua oferta e qualquer #hashtags',
        name: 'offer_description_hint',
      );

  String get availablity => Intl.message(
        'Disponibilidade',
        name: 'availablity',
      );

  String get availablity_description => Intl.message(
        'Descrever minha disponibilidade',
        name: 'availablity_description',
      );

  String get one_to_many_offer_hint => Intl.message(
        'Ex dando aula de python ..',
        name: 'one_to_many_offer_hint',
      );

  String get offer_duration => Intl.message(
        'Duração da oferta',
        name: 'offer_duration',
      );

  String get offer_prep_hours => Intl.message(
        'Nº de horas de preparação',
        name: 'offer_prep_hours',
      );

  String get offer_prep_hours_required => Intl.message(
        'Número de horas de preparação necessárias',
        name: 'offer_prep_hours_required',
      );

  String get offer_number_class_hours => Intl.message(
        'Nº de horas de aula',
        name: 'offer_number_class_hours',
      );

  String get offer_number_class_hours_required => Intl.message(
        'Nº de horas de aula necessárias',
        name: 'offer_number_class_hours_required',
      );

  String get offer_size_class => Intl.message(
        'Tamanho da turma',
        name: 'offer_size_class',
      );

  String get offer_enter_participants => Intl.message(
        'Digite o número de participantes',
        name: 'offer_enter_participants',
      );

  String get offer_class_description => Intl.message(
        'Descrição da classe',
        name: 'offer_class_description',
      );

  String get offer_description_error => Intl.message(
        'Digite alguma descrição da turma',
        name: 'offer_description_error',
      );

  String get offer_start_end_date => Intl.message(
        'Digite as datas de início e término',
        name: 'offer_start_end_date',
      );

  String get validation_error_offer_title => Intl.message(
        'Por favor, indique o assunto da sua oferta',
        name: 'validation_error_offer_title',
      );

  String get validation_error_offer_class_hours => Intl.message(
        'Por favor, indique as horas necessárias para a classe',
        name: 'validation_error_offer_class_hours',
      );

  String get validation_error_hours_not_int => Intl.message(
        'Número introduzido de horas não é válido',
        name: 'validation_error_hours_not_int',
      );

  String get validation_error_offer_prep_hour => Intl.message(
        'Por favor, indique o seu tempo preperation',
        name: 'validation_error_offer_prep_hour',
      );

  String get validation_error_location => Intl.message(
        'Por favor selecionar o local',
        name: 'validation_error_location',
      );

  String get validation_error_class_size_int => Intl.message(
        'Tamanho da classe não pode estar em decimal',
        name: 'validation_error_class_size_int',
      );

  String get validation_error_class_size => Intl.message(
        'Por favor, indique tamanho válido de classe',
        name: 'validation_error_class_size',
      );

  String get validation_error_offer_credit => Intl.message(
        'Nós não podemos publicar esta classe. Há créditos insuficientes da classe. Por favor, revise o tempo Prep ou o número de alunos e submeter a oferta novamente',
        name: 'validation_error_offer_credit',
      );

  String get posted_on => Intl.message(
        'Publicado en',
        name: 'posted_on',
      );

  String get location => Intl.message(
        'Ubicación',
        name: 'location',
      );

  String get offered_by => Intl.message(
        'Ofrecido por',
        name: 'offered_by',
      );

  String get you_created_offer => Intl.message(
        'Creaste esta oferta',
        name: 'you_created_offer',
      );

  String get you_have => Intl.message(
        'Tienes',
        name: 'you_have',
      );

  String get not_yet => Intl.message(
        'aún no',
        name: 'not_yet',
      );

  String get signed_up_for => Intl.message(
        'Ingresado para',
        name: 'signed_up_for',
      );

  String get bookmarked => Intl.message(
        'marcado',
        name: 'bookmarked',
      );

  String get this_offer => Intl.message(
        'esta oferta',
        name: 'this_offer',
      );

  String get details => Intl.message(
        'Detalles',
        name: 'details',
      );

  String get no_offers => Intl.message(
        'No hay ofertas',
        name: 'no_offers',
      );

  String get your_earnings => Intl.message(
        'Sus ganancias',
        name: 'your_earnings',
      );

  String get timebank_earnings => Intl.message(
        'Ganancias del banco de tiempo',
        name: 'timebank_earnings',
      );

  String get no_participants_yet => Intl.message(
        'Aún no hay participantes',
        name: 'no_participants_yet',
      );

  String get bookmarked_offers => Intl.message(
        'Ofertas marcadas',
        name: 'bookmarked_offers',
      );

  String get my_offers => Intl.message(
        'Mis ofertas',
        name: 'my_offers',
      );

  String get offer_help => Intl.message(
        'Ayuda de ofertas',
        name: 'offer_help',
      );

  String get report_members => Intl.message(
        'Membro do relatório',
        name: 'report_members',
      );

  String get report_member_inform => Intl.message(
        'Informe por que você está denunciando esse usuário.',
        name: 'report_member_inform',
      );

  String get report_member_provide_details => Intl.message(
        'Por favor forneça o máximo possível de detalhes',
        name: 'report_member_provide_details',
      );

  String get report => Intl.message(
        'Relatório',
        name: 'report',
      );

  String get reporting_member => Intl.message(
        'Membro relator',
        name: 'reporting_member',
      );

  String get no_data => Intl.message(
        'Datos no encontrados !',
        name: 'no_data',
      );

  String get reported_by => Intl.message(
        'Reportado por',
        name: 'reported_by',
      );

  String get user_removed_from_group => Intl.message(
        'Usuário removido com sucesso do grupo',
        name: 'user_removed_from_group',
      );

  String get user_removed_from_group_failed => Intl.message(
        'O usuário não pode ser excluído deste grupo',
        name: 'user_removed_from_group_failed',
      );

  String get user_has => Intl.message(
        'O usuário possui',
        name: 'user_has',
      );

  String get pending_projects => Intl.message(
        'projetos pendentes',
        name: 'pending_projects',
      );

  String get pending_requests => Intl.message(
        'Solicitações Pendentes',
        name: 'pending_requests',
      );

  String get pending_offers => Intl.message(
        'ofertas pendentes',
        name: 'pending_offers',
      );

  String get clear_transaction => Intl.message(
        'Limpe as transações e tente novamente.',
        name: 'clear_transaction',
      );

  String get remove_self_from_group_error => Intl.message(
        'Não é possível remover-se do grupo. Em vez disso, tente excluir o grupo.',
        name: 'remove_self_from_group_error',
      );

  String get user_removed_from_timebank => Intl.message(
        'O usuário foi removido com sucesso do timebank',
        name: 'user_removed_from_timebank',
      );

  String get user_removed_from_timebank_failed => Intl.message(
        'O usuário não pode ser excluído deste timebank',
        name: 'user_removed_from_timebank_failed',
      );

  String get member_reported => Intl.message(
        'Membro relatado com sucesso',
        name: 'member_reported',
      );

  String get member_reporting_failed => Intl.message(
        'Falha ao denunciar membro! Tente novamente',
        name: 'member_reporting_failed',
      );

  String get reported_member_click_to_view => Intl.message(
        'Clique aqui para ver os usuários denunciados deste timebank',
        name: 'reported_member_click_to_view',
      );

  String get reported_users => Intl.message(
        'Usuários denunciados',
        name: 'reported_users',
      );

  String get reported_members => Intl.message(
        'Membros denunciados',
        name: 'reported_members',
      );

  String get search_something => Intl.message(
        'Buscar algo',
        name: 'search_something',
      );

  String get i_want_to_volunteer => Intl.message(
        'Quiero ser voluntario',
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
        'Versión',
        name: 'help_version',
      );

  String get feedback => Intl.message(
        'Retroalimentación',
        name: 'feedback',
      );

  String get send_feedback => Intl.message(
        'Enviar comentarios',
        name: 'send_feedback',
      );

  String get enter_feedback => Intl.message(
        'Por favor ingrese sus comentarios',
        name: 'enter_feedback',
      );

  String get feedback_messagae => Intl.message(
        'Por favor, háganos saber acerca de sus valiosos comentarios',
        name: 'feedback_messagae',
      );

  String get create_timebank_description => Intl.message(
        'Un TimeBank es una comunidad de voluntarios que se dan y reciben tiempo entre ellos y con la comunidad en general.',
        name: 'create_timebank_description',
      );

  String get timebank_logo => Intl.message(
        'Logo de banco de tiempo',
        name: 'timebank_logo',
      );

  String get timebank_name => Intl.message(
        'Nombra tu banco de tiempo',
        name: 'timebank_name',
      );

  String get timebank_name_hint => Intl.message(
        'Ex: Animais de estimação na cidade, Citizen collab',
        name: 'timebank_name_hint',
      );

  String get timebank_name_error => Intl.message(
        'El nombre del banco de tiempo no puede estar vacío',
        name: 'timebank_name_error',
      );

  String get timebank_name_exists_error => Intl.message(
        'El nombre del banco de tiempo ya existe',
        name: 'timebank_name_exists_error',
      );

  String get timbank_about_hint => Intl.message(
        'Ej: un poco más sobre tu banco de tiempo',
        name: 'timbank_about_hint',
      );

  String get timebank_tell_more => Intl.message(
        'Cuéntanos más sobre tu banco de tiempo.',
        name: 'timebank_tell_more',
      );

  String get timebank_select_tax_percentage => Intl.message(
        'Seleccione porcentaje de impuestos',
        name: 'timebank_select_tax_percentage',
      );

  String get timebank_current_tax_percentage => Intl.message(
        'Porcentaje actual de impuestos',
        name: 'timebank_current_tax_percentage',
      );

  String get timebank_location => Intl.message(
        'Su ubicación del banco de tiempo.',
        name: 'timebank_location',
      );

  String get timebank_location_hint => Intl.message(
        'Indique el lugar o la dirección donde se reúne su comunidad (como un café, una biblioteca o una iglesia).',
        name: 'timebank_location_hint',
      );

  String get timebank_name_exists => Intl.message(
        '¡Ya existe el nombre del banco de tiempo!',
        name: 'timebank_name_exists',
      );

  String get timebank_location_error => Intl.message(
        'Por favor agregue su ubicación de banco de tiempo',
        name: 'timebank_location_error',
      );

  String get timebank_logo_error => Intl.message(
        'El logo del banco de tiempo es obligatorio',
        name: 'timebank_logo_error',
      );

  String get creating_timebank => Intl.message(
        'Crear banco de tiempo',
        name: 'creating_timebank',
      );

  String get timebank_billing_error => Intl.message(
        'Configura los detalles de tu información personal',
        name: 'timebank_billing_error',
      );

  String get timebank_configure_profile_info => Intl.message(
        'Configurar información de perfil',
        name: 'timebank_configure_profile_info',
      );

  String get timebank_profile_info => Intl.message(
        'Informações do perfil',
        name: 'timebank_profile_info',
      );

  String get validation_error_required_fields => Intl.message(
        'El campo no puede dejarse en blanco *',
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
        'Código postal',
        name: 'zip',
      );

  String get country => Intl.message(
        'Nombre del país',
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
        'nombre de empresa',
        name: 'company_name',
      );

  String get continue_text => Intl.message(
        'Seguir',
        name: 'continue_text',
      );

  String get private_timebank => Intl.message(
        'Timebank privado',
        name: 'private_timebank',
      );

  String get updating_details => Intl.message(
        'Atualizando detalhes',
        name: 'updating_details',
      );

  String get edit_profile_information => Intl.message(
        'Editar informações do perfil',
        name: 'edit_profile_information',
      );

  String get selected_users_before => Intl.message(
        'Usuarios seleccionados antes',
        name: 'selected_users_before',
      );

  String get private_timebank_alert => Intl.message(
        'Alerta privada Timebank',
        name: 'private_timebank_alert',
      );

  String get private_timebank_alert_hint => Intl.message(
        'Tenga en cuenta que Private Timebanks no tiene una opción gratuita. Deberá proporcionar sus datos de facturación para continuar creando este banco de tiempo',
        name: 'private_timebank_alert_hint',
      );

  String get additional_notes => Intl.message(
        'Notas adicionales',
        name: 'additional_notes',
      );

  String get prevent_accidental_delete => Intl.message(
        'Exclusão accedental privada',
        name: 'prevent_accidental_delete',
      );

  String get update_request => Intl.message(
        'Solicitação de atualização',
        name: 'update_request',
      );

  String get timebank_offers => Intl.message(
        'Ofertas do Timebank',
        name: 'timebank_offers',
      );

  String get plan_details => Intl.message(
        'Detalles del plan',
        name: 'plan_details',
      );

  String get on_community_plan => Intl.message(
        'Estás en el plan comunitario',
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
        'pagando anualmente \\ \$ 1500 y cargos adicionales de',
        name: 'plan_yearly_1500',
      );

  String get plan_details_quota1 => Intl.message(
        'por transacción facturada mensualmente al exceder la cuota mensual gratuita',
        name: 'plan_details_quota1',
      );

  String get paying => Intl.message(
        'pago',
        name: 'paying',
      );

  String get charges_of => Intl.message(
        'cargos anuales y adicionales de',
        name: 'charges_of',
      );

  String get per_transaction_quota => Intl.message(
        'por transacción facturada anualmente al exceder la cuota mensual gratuita',
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

  String get card_details => Intl.message(
        'DETALLES DE TARJETA',
        name: 'card_details',
      );

  String get add_new => Intl.message(
        'Añadir nuevo',
        name: 'add_new',
      );

  String get no_cards_available => Intl.message(
        'No hay tarjetas disponibles.',
        name: 'no_cards_available',
      );

  String get default_card_note => Intl.message(
        'Nota: mantenga presionado para hacer que la tarjeta sea predeterminada',
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
        'Puede tomar un par de minutos sincronizar su pago',
        name: 'card_sync',
      );

  String get select_group => Intl.message(
        'Selecionar grupo',
        name: 'select_group',
      );

  String get delete_feed => Intl.message(
        'Eliminar feed',
        name: 'delete_feed',
      );

  String get deleting_feed => Intl.message(
        'Eliminar feed',
        name: 'deleting_feed',
      );

  String get delete_feed_confirmation => Intl.message(
        '¿Estás seguro de que deseas eliminar esta fuente de noticias?',
        name: 'delete_feed_confirmation',
      );

  String get create_feed => Intl.message(
        'Crear feed',
        name: 'create_feed',
      );

  String get create_feed_hint => Intl.message(
        'Texto, URL y Hashtags',
        name: 'create_feed_hint',
      );

  String get create_feed_placeholder => Intl.message(
        'Qué te gustaría compartir*',
        name: 'create_feed_placeholder',
      );

  String get creating_feed => Intl.message(
        'Creando feed',
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
        'Alterar anexo',
        name: 'change_attachment',
      );

  String get add_image => Intl.message(
        'Añadir imagen',
        name: 'add_image',
      );

  String get add_attachment => Intl.message(
        'Adicionar imagem / documento',
        name: 'add_attachment',
      );

  String get validation_error_file_size => Intl.message(
        'Arquivos com mais de 10 MB não são permitidos',
        name: 'validation_error_file_size',
      );

  String get large_file_size => Intl.message(
        'Alerta de arquivo grande',
        name: 'large_file_size',
      );

  String get update_feed => Intl.message(
        'Atualizar postagem',
        name: 'update_feed',
      );

  String get updating_feed => Intl.message(
        'Atualizando postagem',
        name: 'updating_feed',
      );

  String get notification_alerts => Intl.message(
        'Alertas de notificación\n\n',
        name: 'notification_alerts',
      );

  String get request_accepted => Intl.message(
        'El miembro ha aceptado una solicitud y está esperando su aprobación',
        name: 'request_accepted',
      );

  String get request_completed => Intl.message(
        'El miembro reclama créditos de tiempo y está esperando su aprobación',
        name: 'request_completed',
      );

  String get join_request_message => Intl.message(
        'Solicitud de miembro para unirse a',
        name: 'join_request_message',
      );

  String get offer_debit => Intl.message(
        'Débito para una o varias ofertas',
        name: 'offer_debit',
      );

  String get member_exits => Intl.message(
        'El miembro sale de a',
        name: 'member_exits',
      );

  String get deletion_request_message => Intl.message(
        'No se pudo procesar la solicitud de eliminación (debido a transacciones pendientes)',
        name: 'deletion_request_message',
      );

  String get recieved_credits_one_to_many => Intl.message(
        'Crédito recibido por una o varias ofertas',
        name: 'recieved_credits_one_to_many',
      );

  String get click_to_see_interests => Intl.message(
        'Clique aqui para ver seus interesses',
        name: 'click_to_see_interests',
      );

  String get click_to_see_skills => Intl.message(
        'Clique aqui para ver suas habilidades',
        name: 'click_to_see_skills',
      );

  String get my_language => Intl.message(
        'Minha língua',
        name: 'my_language',
      );

  String get my_timezone => Intl.message(
        'Meu fuso horário',
        name: 'my_timezone',
      );

  String get select_timebank => Intl.message(
        'Seleccione un banco de tiempo',
        name: 'select_timebank',
      );

  String get name => Intl.message(
        'Nome',
        name: 'name',
      );

  String get add_bio => Intl.message(
        'Adicione sua biografia',
        name: 'add_bio',
      );

  String get enter_name => Intl.message(
        'Digite o nome',
        name: 'enter_name',
      );

  String get update_name => Intl.message(
        'Atualizar nome',
        name: 'update_name',
      );

  String get enter_name_hint => Intl.message(
        'Digite o nome para atualizar',
        name: 'enter_name_hint',
      );

  String get update_bio => Intl.message(
        'Atualizar biografia',
        name: 'update_bio',
      );

  String get update_bio_hint => Intl.message(
        'Insira a biografia para atualizar',
        name: 'update_bio_hint',
      );

  String get enter_bio => Intl.message(
        'Inserir biografia',
        name: 'enter_bio',
      );

  String get available_as_needed => Intl.message(
        'Disponible según sea necesario - Abierto a ofertas',
        name: 'available_as_needed',
      );

  String get would_be_unblocked => Intl.message(
        'estaría desbloqueado',
        name: 'would_be_unblocked',
      );

  String get jobs => Intl.message(
        'Trabajos',
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
        'Aún no hay calificaciones',
        name: 'no_ratings_yet',
      );

  String get message => Intl.message(
        'Mensaje',
        name: 'message',
      );

  String get not_completed_any_tasks => Intl.message(
        'no completó ninguna tarea',
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
        'Fecha:',
        name: 'date',
      );

  String get search_template_hint => Intl.message(
        'Ingrese el nombre de una plantilla de proyecto',
        name: 'search_template_hint',
      );

  String get create_project_from_template => Intl.message(
        'Crear proyecto desde plantilla',
        name: 'create_project_from_template',
      );

  String get create_new_project => Intl.message(
        'Crear nuevo proyecto',
        name: 'create_new_project',
      );

  String get no_templates_found => Intl.message(
        'No se encontraron plantillas',
        name: 'no_templates_found',
      );

  String get select_template => Intl.message(
        'Seleccione una plantilla de la lista de plantillas disponibles.',
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
        'Reserve um momento para refletir sobre sua experiência e compartilhar sua apreciação escrevendo uma breve resenha.',
        name: 'review_feedback_message',
      );

  String get submit => Intl.message(
        'Enviar',
        name: 'submit',
      );

  String get review => Intl.message(
        'Reveja',
        name: 'review',
      );

  String get redirecting_to_messages => Intl.message(
        'Redireccionando a mensajes',
        name: 'redirecting_to_messages',
      );

  String get completing_task => Intl.message(
        'Completando tarea',
        name: 'completing_task',
      );

  String get total_spent => Intl.message(
        'Gasto total',
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
        'No hay solicitudes pendientes.',
        name: 'no_pending_requests',
      );

  String get choose_suitable_plan => Intl.message(
        'Elige un plan adecuado',
        name: 'choose_suitable_plan',
      );

  String get click_for_more_info => Intl.message(
        'Haga clic aquí para más información',
        name: 'click_for_more_info',
      );

  String get taking_to_new_timebank => Intl.message(
        'Llevarte a tu nuevo banco de tiempo ...',
        name: 'taking_to_new_timebank',
      );

  String get bill_me => Intl.message(
        'facturarme',
        name: 'bill_me',
      );

  String get bill_me_info1 => Intl.message(
        'Esto está disponible solo para usuarios que tienen acuerdos previos con Seva Exchange. Por favor envíe un correo electrónico a billme@sevaexchange.com para más detalles.',
        name: 'bill_me_info1',
      );

  String get bill_me_info2 => Intl.message(
        'Solo los usuarios que han sido aprobados a priori pueden marcar la casilla \"Bill Me\". Si desea hacer esto, envíe un correo electrónico a billme@sevaexchange.com',
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
        'Escoger',
        name: 'choose',
      );

  String get plan_change => Intl.message(
        'Cambio de plan',
        name: 'plan_change',
      );

  String get ownership_success => Intl.message(
        '¡Felicidades! Ahora eres el nuevo propietario del Banco de tiempo ',
        name: 'ownership_success',
      );

  String get change => Intl.message(
        'Cambio',
        name: 'change',
      );

  String get contact_seva_to_change_plan => Intl.message(
        'Comuníquese con el soporte de SevaX para cambiar los planes.',
        name: 'contact_seva_to_change_plan',
      );

  String get changing_ownership_of => Intl.message(
        'Cambio de propiedad de este ',
        name: 'changing_ownership_of',
      );

  String get to_other_admin => Intl.message(
        ' a otro administrador',
        name: 'to_other_admin',
      );

  String get change_to => Intl.message(
        'Cambiar a',
        name: 'change_to',
      );

  String get invitation_sent1 => Intl.message(
        'Hemos enviado su invitación de transferencia de propiedad. Seguirás siendo el propietario de Timebank ',
        name: 'invitation_sent1',
      );

  String get invitation_sent2 => Intl.message(
        ' hasta ',
        name: 'invitation_sent2',
      );

  String get invitation_sent3 => Intl.message(
        ' acepta la invitación y proporciona su nueva información de facturación.',
        name: 'invitation_sent3',
      );

  String get by_accepting_owner_timebank => Intl.message(
        'Al aceptar, se convertirá en propietario del banco de tiempo',
        name: 'by_accepting_owner_timebank',
      );

  String get select_user => Intl.message(
        'Por favor seleccione un usuario',
        name: 'select_user',
      );

  String get change_ownership_pending_task_message => Intl.message(
        'Tienes tareas pendientes. Complete estas tareas antes de poder transferir la propiedad',
        name: 'change_ownership_pending_task_message',
      );

  String get change_ownership_pending_payment1 => Intl.message(
        'Tienes un pago pendiente de ',
        name: 'change_ownership_pending_payment1',
      );

  String get change_ownership_pending_payment2 => Intl.message(
        '. Complete estos pagos antes de poder transferir la propiedad',
        name: 'change_ownership_pending_payment2',
      );

  String get search_admin => Intl.message(
        'Administrateur de recherche',
        name: 'search_admin',
      );

  String get change_ownership_message1 => Intl.message(
        'Eres el nuevo propietario de Timebank ',
        name: 'change_ownership_message1',
      );

  String get change_ownership_message2 => Intl.message(
        ' Debes aceptarlo para completar el proceso.',
        name: 'change_ownership_message2',
      );

  String get change_ownership_advisory => Intl.message(
        ' Debe proporcionar los detalles de facturación de este Timebank, incluida la nueva dirección de facturación. La transferencia de propiedad no se completará hasta que se haga esto.',
        name: 'change_ownership_advisory',
      );

  String get change_ownership_already_invited => Intl.message(
        ' Ya invitado.',
        name: 'change_ownership_already_invited',
      );

  String get donate => Intl.message(
        'Donar',
        name: 'donate',
      );

  String get donate_to_timebank => Intl.message(
        'Done monedas seva al banco de tiempo',
        name: 'donate_to_timebank',
      );

  String get insufficient_credits_to_donate => Intl.message(
        '¡No tienes suficientes créditos para donar!',
        name: 'insufficient_credits_to_donate',
      );

  String get current_seva_credit => Intl.message(
        'Sus monedas seva actuales son',
        name: 'current_seva_credit',
      );

  String get donate_message => Intl.message(
        'Al hacer clic en donar se ajustará su saldo',
        name: 'donate_message',
      );

  String get zero_credit_donation_error => Intl.message(
        'No puedes donar 0 créditos',
        name: 'zero_credit_donation_error',
      );

  String get negative_credit_donation_error => Intl.message(
        'Você não pode doar menos de 0 créditos',
        name: 'negative_credit_donation_error',
      );

  String get empty_credit_donation_error => Intl.message(
        'Donate some credits',
        name: 'empty_credit_donation_error',
      );

  String get number_of_seva_credit => Intl.message(
        'No of su créditos',
        name: 'number_of_seva_credit',
      );

  String get donation_success => Intl.message(
        'Has donado créditos con éxito',
        name: 'donation_success',
      );

  String get sending_invitation => Intl.message(
        'Enviando convite ...',
        name: 'sending_invitation',
      );

  String get ownership_transfer_error => Intl.message(
        'Ocorreu um erro! Por favor volte mais tarde e tente novamente.',
        name: 'ownership_transfer_error',
      );

  String get add_members => Intl.message(
        'Adicionar membros',
        name: 'add_members',
      );

  String get group_logo => Intl.message(
        'Logotipo do grupo',
        name: 'group_logo',
      );

  String get name_your_group => Intl.message(
        'Dê um nome ao seu grupo',
        name: 'name_your_group',
      );

  String get bit_more_about_group => Intl.message(
        'Ex: Um pouco mais sobre o seu grupo',
        name: 'bit_more_about_group',
      );

  String get private_group => Intl.message(
        'Grupo Privado',
        name: 'private_group',
      );

  String get is_pin_at_right_place => Intl.message(
        'Este pino está no lugar certo?',
        name: 'is_pin_at_right_place',
      );

  String get find_timebanks => Intl.message(
        'Encontrar bancos de tiempo',
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
        'Ver pedidos',
        name: 'view_requests',
      );

  String get delete_group => Intl.message(
        'Excluir grupo',
        name: 'delete_group',
      );

  String get settings => Intl.message(
        'Definições',
        name: 'settings',
      );

  String get invite_members => Intl.message(
        'Convidar membros',
        name: 'invite_members',
      );

  String get invite_via_code => Intl.message(
        'Convidar via código',
        name: 'invite_via_code',
      );

  String get bulk_invite_users_csv => Intl.message(
        'Invitación masiva de usuarios por CSV',
        name: 'bulk_invite_users_csv',
      );

  String get csv_message1 => Intl.message(
        'Descargue la plantilla CSV en',
        name: 'csv_message1',
      );

  String get csv_message2 => Intl.message(
        'Rellena las usuarios que te gustaría agregar ',
        name: 'csv_message2',
      );

  String get csv_message3 => Intl.message(
        'luego cargue el archivo CSV',
        name: 'csv_message3',
      );

  String get download_sample_csv => Intl.message(
        'Descargue un archivo CSV de muestra',
        name: 'download_sample_csv',
      );

  String get choose_csv => Intl.message(
        'Elija el archivo CSV para invitar a miembros de forma masiva',
        name: 'choose_csv',
      );

  String get csv_size_limit => Intl.message(
        'NOTA: el tamaño máximo del archivo es de 1 MB',
        name: 'csv_size_limit',
      );

  String get uploading_csv => Intl.message(
        'Subir archivo CSV',
        name: 'uploading_csv',
      );

  String get uploaded_successfully => Intl.message(
        'Subido correctamente',
        name: 'uploaded_successfully',
      );

  String get csv_error => Intl.message(
        'Seleccione primero un archivo CSV antes de cargar',
        name: 'csv_error',
      );

  String get upload => Intl.message(
        'Subir',
        name: 'upload',
      );

  String get large_file_alert => Intl.message(
        'Alerta de arquivo grande',
        name: 'large_file_alert',
      );

  String get csv_large_file_message => Intl.message(
        'No se permiten archivos de más de 1 MB.',
        name: 'csv_large_file_message',
      );

  String get not_found => Intl.message(
        'não encontrado',
        name: 'not_found',
      );

  String get resend_invite => Intl.message(
        'Reenviar convite',
        name: 'resend_invite',
      );

  String get add => Intl.message(
        'Adicionar',
        name: 'add',
      );

  String get no_codes_generated => Intl.message(
        'Nenhum código gerado ainda.',
        name: 'no_codes_generated',
      );

  String get not_yet_redeemed => Intl.message(
        'Ainda não resgatados',
        name: 'not_yet_redeemed',
      );

  String get redeemed_by => Intl.message(
        'Resgatado por',
        name: 'redeemed_by',
      );

  String get timebank_code => Intl.message(
        'Código do timebank:',
        name: 'timebank_code',
      );

  String get expired => Intl.message(
        'Expirado',
        name: 'expired',
      );

  String get active => Intl.message(
        'Ativo',
        name: 'active',
      );

  String get share_code => Intl.message(
        'Compartilhar código',
        name: 'share_code',
      );

  String get invite_message => Intl.message(
        'Timebank. Timebanks são comunidades que permitem que você seja voluntário e também receba créditos de tempo para fazer as coisas por você. Use o código',
        name: 'invite_message',
      );

  String get invite_prompt => Intl.message(
        'Quando solicitado a ingressar neste Timebank. Faça o download do aplicativo a partir dos links fornecidos em https://sevaexchange.page.link/sevaxapp',
        name: 'invite_prompt',
      );

  String get code_generated => Intl.message(
        'Código gerado',
        name: 'code_generated',
      );

  String get is_your_code => Intl.message(
        'é o seu código.',
        name: 'is_your_code',
      );

  String get publish_code => Intl.message(
        'Código de publicação',
        name: 'publish_code',
      );

  String get invite_via_email => Intl.message(
        'Convidar membros por e-mail',
        name: 'invite_via_email',
      );

  String get no_member_found => Intl.message(
        'No se ha encontrado ningún miembro',
        name: 'no_member_found',
      );

  String get declined => Intl.message(
        'rechazado',
        name: 'declined',
      );

  String get search_by_email_name => Intl.message(
        'Buscar miembros por correo electrónico, nombre',
        name: 'search_by_email_name',
      );

  String get no_groups_found => Intl.message(
        'No se encontraron grupos.',
        name: 'no_groups_found',
      );

  String get no_image_available => Intl.message(
        'No hay imagen disponible',
        name: 'no_image_available',
      );

  String get group_description => Intl.message(
        'Los grupos dentro de un banco de tiempo permiten actividades granulares. Puedes unirte a uno de los grupos a continuación o crear tu propio grupo',
        name: 'group_description',
      );

  String get updating_users => Intl.message(
        'Atualizando usuários',
        name: 'updating_users',
      );

  String get admins_organizers => Intl.message(
        'Administradores e Organizadores',
        name: 'admins_organizers',
      );

  String get enter_reason_to_exit => Intl.message(
        'Digite o motivo para sair',
        name: 'enter_reason_to_exit',
      );

  String get enter_reason_to_exit_hint => Intl.message(
        'Digite o motivo para sair',
        name: 'enter_reason_to_exit_hint',
      );

  String get member_removal_confirmation => Intl.message(
        'Você tem certeza que deseja remover',
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
        'Sus créditos de banco de tiempo seva son',
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
        'No puede prestar menos de 0 créditos',
        name: 'negative_credit_loan_error',
      );

  String get empty_credit_loan_error => Intl.message(
        'Préstamo de algunos créditos',
        name: 'empty_credit_loan_error',
      );

  String get loan_success => Intl.message(
        'Has prestado créditos con éxito',
        name: 'loan_success',
      );

  String get co_ordinators => Intl.message(
        'Coordenadores',
        name: 'co_ordinators',
      );

  String get remove => Intl.message(
        'Retirar',
        name: 'remove',
      );

  String get promote => Intl.message(
        'Promover',
        name: 'promote',
      );

  String get demote => Intl.message(
        'Rebaixar',
        name: 'demote',
      );

  String get billing => Intl.message(
        'Facturación',
        name: 'billing',
      );

  String get edit_timebank => Intl.message(
        'Editar banco de tiempo',
        name: 'edit_timebank',
      );

  String get delete_timebank => Intl.message(
        'Excluir Timebank',
        name: 'delete_timebank',
      );

  String get remove_user => Intl.message(
        'Remover usuário',
        name: 'remove_user',
      );

  String get exit_user => Intl.message(
        'Sair do usuário',
        name: 'exit_user',
      );

  String get transfer_data_hint => Intl.message(
        'Transfira a propriedade dos dados deste usuário para outro usuário, como propriedade do grupo.',
        name: 'transfer_data_hint',
      );

  String get transfer_to => Intl.message(
        'Transferir para',
        name: 'transfer_to',
      );

  String get search_user => Intl.message(
        'Pesquisar um usuário',
        name: 'search_user',
      );

  String get transer_hint_data_deletion => Intl.message(
        'Todos os dados não transferidos serão excluídos.',
        name: 'transer_hint_data_deletion',
      );

  String get user_removal_success => Intl.message(
        'O usuário foi removido com sucesso do timebank',
        name: 'user_removal_success',
      );

  String get error_occured => Intl.message(
        'Ocorreu um erro! Por favor volte mais tarde e tente novamente.',
        name: 'error_occured',
      );

  String get create_group => Intl.message(
        'Criar grupo',
        name: 'create_group',
      );

  String get group_exists => Intl.message(
        'O nome do grupo já existe',
        name: 'group_exists',
      );

  String get group_subset => Intl.message(
        'Grupo é um subconjunto de um timebank que pode ser temporário. Ex: comitês, equipes de projeto.',
        name: 'group_subset',
      );

  String get part_of => Intl.message(
        'Parte de',
        name: 'part_of',
      );

  String get global_timebank => Intl.message(
        'Red mundial de bancos de tiempo SevaX',
        name: 'global_timebank',
      );

  String get getting_volunteers => Intl.message(
        'Conseguir voluntarios ...',
        name: 'getting_volunteers',
      );

  String get no_volunteers_yet => Intl.message(
        'Ningún voluntario se unió todavía.',
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
        'Voluntarios',
        name: 'volunteers',
      );

  String get and_others => Intl.message(
        'y otros',
        name: 'and_others',
      );

  String get admins => Intl.message(
        'Admins',
        name: 'admins',
      );

  String get remove_as_admin => Intl.message(
        'Remover como administrador',
        name: 'remove_as_admin',
      );

  String get add_as_admin => Intl.message(
        'Adicionar como administrador',
        name: 'add_as_admin',
      );

  String get view_profile => Intl.message(
        'Ver perfil',
        name: 'view_profile',
      );

  String get remove_member => Intl.message(
        'Remover membro',
        name: 'remove_member',
      );

  String get from_timebank_members => Intl.message(
        'dos membros do timebank?',
        name: 'from_timebank_members',
      );

  String get no_volunteers_available => Intl.message(
        'Não há voluntários disponíveis',
        name: 'no_volunteers_available',
      );

  String get select_volunteer => Intl.message(
        'Selecionar voluntários',
        name: 'select_volunteer',
      );

  String get no_requests => Intl.message(
        'Sin solicitudes',
        name: 'no_requests',
      );

  String get switching_timebank => Intl.message(
        'Mudando o Timebank',
        name: 'switching_timebank',
      );

  String get tap_to_delete => Intl.message(
        'Toque para excluir este item',
        name: 'tap_to_delete',
      );

  String get clear => Intl.message(
        'Clear',
        name: 'clear',
      );

  String get currently_selected => Intl.message(
        'Atualmente selecionado',
        name: 'currently_selected',
      );

  String get tap_to_remove_tooltip => Intl.message(
        'Itens (toque para remover)',
        name: 'tap_to_remove_tooltip',
      );

  String get timebank_exit => Intl.message(
        'Saída do Timebank',
        name: 'timebank_exit',
      );

  String get has_exited_from => Intl.message(
        'saiu de',
        name: 'has_exited_from',
      );

  String get tap_to_view_details => Intl.message(
        'Toque para ver os detalhes',
        name: 'tap_to_view_details',
      );

  String get invited_to_timebank_message => Intl.message(
        'Impressionante! Você está convidado a participar de um Timebank',
        name: 'invited_to_timebank_message',
      );

  String get invitation_email_body => Intl.message(
        '',
        name: 'invitation_email_body',
      );

  String get open_settings => Intl.message(
        'Configuración abierta',
        name: 'open_settings',
      );

  String get failed_to_fetch_location => Intl.message(
        'Error al recuperar la ubicación *',
        name: 'failed_to_fetch_location',
      );

  String get marker => Intl.message(
        'Marcador',
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

  String get profanity_alert => Intl.message(
        'Alerta de blasfemias',
        name: 'profanity_alert',
      );

  String get profanity_image_alert => Intl.message(
        'La aplicación SevaX tiene la política de no permitir imágenes profanas, explícitas o violentas. Por favor usa otra imagen.',
        name: 'profanity_image_alert',
      );

  String get profanity_text_alert => Intl.message(
        'La aplicación SevaX tiene una política de no permitir lenguaje profano o explícito. Por favor revisa tu texto.',
        name: 'profanity_text_alert',
      );

  String get upload_cv_resume => Intl.message(
        'Upload my CV/Resume',
        name: 'upload_cv_resume',
      );

  String get cv_message => Intl.message(
        'CV will help out to provide more details',
        name: 'cv_message',
      );

  String get replace_cv => Intl.message(
        'Replace CV',
        name: 'replace_cv',
      );

  String get choose_pdf_file => Intl.message(
        'Elija archivo pdf',
        name: 'choose_pdf_file',
      );

  String get validation_error_cv_size => Intl.message(
        'NOTA: el tamaño máximo del archivo es de 10 MB',
        name: 'validation_error_cv_size',
      );

  String get validation_error_cv_not_selected => Intl.message(
        'Seleccione un archivo de CV antes de cargarlo',
        name: 'validation_error_cv_not_selected',
      );

  String get enter_reason_to_delete => Intl.message(
        'Ingrese el motivo para eliminar',
        name: 'enter_reason_to_delete',
      );

  String get enter_reason_to_delete_error => Intl.message(
        'Por favor, introduzca el motivo para eliminar',
        name: 'enter_reason_to_delete_error',
      );

  String get delete_request_confirmation => Intl.message(
        '¿Estás seguro de que deseas eliminar esta solicitud?',
        name: 'delete_request_confirmation',
      );

  String get will_be_added_to_request => Intl.message(
        'se agregará automáticamente a la solicitud.',
        name: 'will_be_added_to_request',
      );

  String get updating => Intl.message(
        'Actualizando',
        name: 'updating',
      );

  String get skipping => Intl.message(
        'Salto a la comba',
        name: 'skipping',
      );

  String get check_email => Intl.message(
        'Ahora, mira tu correo.',
        name: 'check_email',
      );

  String get thanks => Intl.message(
        '¡Gracias!',
        name: 'thanks',
      );

  String hour(num count) => Intl.message(
        '${Intl.plural(count, one: 'Hora', other: 'Horas', args: [count])}',
        name: 'hour',        
        args: [count],
      );

  String timebank_project(num count) => Intl.message(
        '${Intl.plural(count, one: 'Proyecto de banco de tiempo', other: 'Proyectos de banco de tiempo', args: [count])}',
        name: 'timebank_project',        
        args: [count],
      );

  String personal_project(num count) => Intl.message(
        '${Intl.plural(count, one: 'Proyecto personal', other: 'Proyectos personales', args: [count])}',
        name: 'personal_project',        
        args: [count],
      );

  String personal_request(num count) => Intl.message(
        '${Intl.plural(count, one: 'Solicitud personal', other: 'Solicitudes personales', args: [count])}',
        name: 'personal_request',        
        args: [count],
      );

  String timebank_request(num count) => Intl.message(
        '${Intl.plural(count, one: 'Solicitud de banco de tiempo', other: 'Solicitudes de banco de tiempo', args: [count])}',
        name: 'timebank_request',        
        args: [count],
      );

  String members_selected(num count) => Intl.message(
        '${Intl.plural(count, one: 'Miembro seleccionado', other: 'Miembros seleccionados', args: [count])}',
        name: 'members_selected',        
        args: [count],
      );

  String volunteers_selected(num count) => Intl.message(
        '${Intl.plural(count, one: 'Voluntario seleccionado', other: 'Voluntarios seleccionados', args: [count])}',
        name: 'volunteers_selected',        
        args: [count],
      );

  String user(num count) => Intl.message(
        '${Intl.plural(count, one: 'usuario', other: 'usuarios', args: [count])}',
        name: 'user',        
        args: [count],
      );

  String other(num count) => Intl.message(
        '${Intl.plural(count, one: 'Otro', other: 'Otros', args: [count])}',
        name: 'other',        
        args: [count],
      );

  String subscription(num count) => Intl.message(
        '${Intl.plural(count, one: 'Suscripción', other: 'Suscripciones', args: [count])}',
        name: 'subscription',        
        args: [count],
      );

  String get max_credits => Intl.message(
        'Créditos máximos *',
        name: 'max_credits',
      );

  String get max_credit_hint => Intl.message(
        'Créditos máximos a otorgar por voluntario',
        name: 'max_credit_hint',
      );

  String get dont_allow => Intl.message(
        'No permitir',
        name: 'dont_allow',
      );

  String get push_notification_message => Intl.message(
        'La aplicación SevaX desea enviarle notificaciones automáticas. Las notificaciones pueden incluir alertas y recordatorios.',
        name: 'push_notification_message',
      );

  String get only_pdf_files_allowed => Intl.message(
        'Solo se permiten archivos PDF',
        name: 'only_pdf_files_allowed',
      );

  String get delete_request => Intl.message(
        'Borrar petición',
        name: 'delete_request',
      );

  String get delete_offer => Intl.message(
        'Eliminar oferta',
        name: 'delete_offer',
      );

  String get delete_offer_confirmation => Intl.message(
        '¿Está seguro de que desea eliminar esta oferta?',
        name: 'delete_offer_confirmation',
      );

  String get extension_alert => Intl.message(
        'Alerta de extensión',
        name: 'extension_alert',
      );

  String get only_csv_allowed => Intl.message(
        'Solo se permiten archivos CSV',
        name: 'only_csv_allowed',
      );

  String get no_members => Intl.message(
        'Sin miembros',
        name: 'no_members',
      );

  String get cancel_offer => Intl.message(
        'Cancelar oferta',
        name: 'cancel_offer',
      );

  String get cancel_offer_confirmation => Intl.message(
        '¿Estás seguro de que deseas cancelar la oferta?',
        name: 'cancel_offer_confirmation',
      );

  String get recurring => Intl.message(
        'Periódico',
        name: 'recurring',
      );

  String get request_credits_again => Intl.message(
        '¿Está seguro de que desea volver a solicitar créditos?',
        name: 'request_credits_again',
      );

  String get cant_perfrom_action_offer => Intl.message(
        'No puede realizar ninguna acción antes de que finalice la oferta.',
        name: 'cant_perfrom_action_offer',
      );

  String get time_left => Intl.message(
        'Tiempo restante',
        name: 'time_left',
      );

  String get days_available => Intl.message(
        'Días disponibles',
        name: 'days_available',
      );

  String get this_is_repeating_event => Intl.message(
        'Este es un evento que se repite',
        name: 'this_is_repeating_event',
      );

  String get edit_this_event => Intl.message(
        'Editar solo este evento',
        name: 'edit_this_event',
      );

  String get edit_subsequent_event => Intl.message(
        'Editar eventos posteriores',
        name: 'edit_subsequent_event',
      );

  String get left => Intl.message(
        'izquierda',
        name: 'left',
      );

  String get cant_exit_group => Intl.message(
        'No puedes salir de este grupo',
        name: 'cant_exit_group',
      );

  String get cant_exit_timebank => Intl.message(
        'no puede salir de este banco de tiempo',
        name: 'cant_exit_timebank',
      );

  String get add_image_url => Intl.message(
        'Agregar URL de imagen',
        name: 'add_image_url',
      );

  String get image_url => Intl.message(
        'URL de la imagen',
        name: 'image_url',
      );

  String day(num count) => Intl.message(
        '${Intl.plural(count, one: 'Día', other: 'Dias', args: [count])}',
        name: 'day',        
        args: [count],
      );

  String year(num count) => Intl.message(
        '${Intl.plural(count, one: 'Año', other: 'Años', args: [count])}',
        name: 'year',        
        args: [count],
      );

  String get lifetime => Intl.message(
        'Toda la vida',
        name: 'lifetime',
      );

  String get raised => Intl.message(
        'Elevado',
        name: 'raised',
      );

  String get donated => Intl.message(
        'Donado',
        name: 'donated',
      );

  String get items_collected => Intl.message(
        'Elementos recolectados',
        name: 'items_collected',
      );

  String get items_donated => Intl.message(
        'Artículos donados',
        name: 'items_donated',
      );

  String get donations => Intl.message(
        'Donaciones',
        name: 'donations',
      );

  String get items => Intl.message(
        'Artículos',
        name: 'items',
      );

  String get enter_valid_amount => Intl.message(
        'Ingrese una cantidad válida',
        name: 'enter_valid_amount',
      );

  String get minmum_amount => Intl.message(
        'La cantidad mínima es',
        name: 'minmum_amount',
      );

  String get select_goods_category => Intl.message(
        'Seleccione una categoría de bienes',
        name: 'select_goods_category',
      );

  String get pledge => Intl.message(
        'Promesa',
        name: 'pledge',
      );

  String get do_it_later => Intl.message(
        'Hazlo después',
        name: 'do_it_later',
      );

  String get tell_what_you_donated => Intl.message(
        'Cuéntanos que has donado',
        name: 'tell_what_you_donated',
      );

  String get describe_goods => Intl.message(
        'Describa sus productos y seleccione de la casilla de verificación a continuación',
        name: 'describe_goods',
      );

  String get payment_link_description => Intl.message(
        'Utilice el enlace a continuación para donar y, una vez hecho, haga una promesa de cuánto ha donado.',
        name: 'payment_link_description',
      );

  String get donation_description_one => Intl.message(
        'Genial, has elegido donar por',
        name: 'donation_description_one',
      );

  String get donation_description_two => Intl.message(
        'un mínimo de donaciones es',
        name: 'donation_description_two',
      );

  String get donation_description_three => Intl.message(
        'DÓLAR ESTADOUNIDENSE. Haga clic en el enlace a continuación para realizar la donación.',
        name: 'donation_description_three',
      );

  String get add_amount_donated => Intl.message(
        'Agregue la cantidad que ha donado.',
        name: 'add_amount_donated',
      );

  String get amount_donated => Intl.message(
        'Cantidad donada?',
        name: 'amount_donated',
      );

  String get acknowledge => Intl.message(
        'Reconocer',
        name: 'acknowledge',
      );

  String get modify => Intl.message(
        'Modificar',
        name: 'modify',
      );

  String get by_accepting => Intl.message(
        'Al aceptar,',
        name: 'by_accepting',
      );

  String get will_added_to_donors => Intl.message(
        'se agregará a la lista de donantes.',
        name: 'will_added_to_donors',
      );

  String get no_donation_yet => Intl.message(
        'Aún no hay donaciones',
        name: 'no_donation_yet',
      );

  String get donation_acknowledge => Intl.message(
        'Reconocimiento de donación',
        name: 'donation_acknowledge',
      );

  String get cv_resume => Intl.message(
        'CV / CV',
        name: 'cv_resume',
      );

  String get pledged => Intl.message(
        'Prometido',
        name: 'pledged',
      );

  String get goods => Intl.message(
        'Bienes',
        name: 'goods',
      );

  String get cash => Intl.message(
        'Efectivo',
        name: 'cash',
      );

  String get received => Intl.message(
        'Recibido',
        name: 'received',
      );

  String get total => Intl.message(
        'Total',
        name: 'total',
      );

  String get recurringDays_err => Intl.message(
        'Los días recurrentes no pueden estar vacíos',
        name: 'recurringDays_err',
      );

  String get calendars_popup_desc => Intl.message(
        'Puede sincronizar el calendario de eventos de SevaX con sus calendarios de Google, Outlook o iCal. Seleccione el icono apropiado para sincronizar el calendario.',
        name: 'calendars_popup_desc',
      );

  String get notifications_demoted_title => Intl.message(
        'Ha sido degradado de administrador',
        name: 'notifications_demoted_title',
      );

  String get notifications_demoted_subtitle_phrase => Intl.message(
        'lo ha degradado de ser administrador de la',
        name: 'notifications_demoted_subtitle_phrase',
      );

  String get notifications_promoted_title => Intl.message(
        'Ha sido ascendido a administrador',
        name: 'notifications_promoted_title',
      );

  String get notifications_promoted_subtitle_phrase => Intl.message(
        'te ha ascendido a administrador de',
        name: 'notifications_promoted_subtitle_phrase',
      );

  String get notifications_approved_withdrawn_title => Intl.message(
        'Miembro retirado',
        name: 'notifications_approved_withdrawn_title',
      );

  String get notifications_approved_withdrawn_subtitle => Intl.message(
        'se ha retirado de',
        name: 'notifications_approved_withdrawn_subtitle',
      );

  String get otm_offer_cancelled_title => Intl.message(
        'Oferta de uno a muchos cancelada',
        name: 'otm_offer_cancelled_title',
      );

  String get otm_offer_cancelled_subtitle => Intl.message(
        'Oferta cancelada por el creador',
        name: 'otm_offer_cancelled_subtitle',
      );

  String get notifications_credited_msg => Intl.message(
        'Se han acreditado monedas Seva en su cuenta',
        name: 'notifications_credited_msg',
      );

  String get notifications_debited_msg => Intl.message(
        'Seva monedasMoMonthlyed from your account',
        name: 'notifications_debited_msg',
      );

  String get recurring_list_heading => Intl.message(
        'Lista recurrente',
        name: 'recurring_list_heading',
      );

  String get recuring_weekly_on => Intl.message(
        'Semanalmente el',
        name: 'recuring_weekly_on',
      );

  String get invoice_and_reports => Intl.message(
        'Factura e informes',
        name: 'invoice_and_reports',
      );

  String get invoice_reports_list => Intl.message(
        'Lista de facturas / informes',
        name: 'invoice_reports_list',
      );

  String get invoice_note1 => Intl.message(
        'Esta factura es por el período de facturación de',
        name: 'invoice_note1',
      );

  String get invoice_note2 => Intl.message(
        'Saludos desde *** nombre de la empresa. Aquí está la factura por su uso de los servicios *** appname durante el período anterior. En la sección de facturación, en la pestaña Administrar, se encuentra disponible información adicional sobre los cargos por servicios individuales y el historial de facturación.',
        name: 'invoice_note2',
      );

  String get initial_charges => Intl.message(
        'Cargos iniciales',
        name: 'initial_charges',
      );

  String get additional_billable_transactions => Intl.message(
        'Transacciones facturables adicionales',
        name: 'additional_billable_transactions',
      );

  String get discounted_transactions_msg => Intl.message(
        'Transacciones facturables con descuento según su plan actual',
        name: 'discounted_transactions_msg',
      );

  String get address_header => Intl.message(
        'Dirección de facturación',
        name: 'address_header',
      );

  String get account_no => Intl.message(
        'Número de cuenta',
        name: 'account_no',
      );

  String get billing_stmt => Intl.message(
        'Estado de cuenta',
        name: 'billing_stmt',
      );

  String get billing_stmt_no => Intl.message(
        'Número de declaración',
        name: 'billing_stmt_no',
      );

  String get billing_stmt_date => Intl.message(
        'Fecha de declaración',
        name: 'billing_stmt_date',
      );

  String get request_type => Intl.message(
        'Tipo de solicitud*',
        name: 'request_type',
      );

  String get request_type_time => Intl.message(
        'Hora',
        name: 'request_type_time',
      );

  String get request_type_cash => Intl.message(
        'Efectivo',
        name: 'request_type_cash',
      );

  String get request_type_goods => Intl.message(
        'Bienes',
        name: 'request_type_goods',
      );

  String get request_description_hint_goods => Intl.message(
        'Por ejemplo: especifique la causa de la solicitud de bienes y cualquier #hashtags',
        name: 'request_description_hint_goods',
      );

  String get request_target_donation => Intl.message(
        'Donación objetivo *',
        name: 'request_target_donation',
      );

  String get request_target_donation_hint => Intl.message(
        'Ej .: \$ 100',
        name: 'request_target_donation_hint',
      );

  String get request_min_donation => Intl.message(
        'Cantidad mínima por socio *',
        name: 'request_min_donation',
      );

  String get request_goods_description => Intl.message(
        'Seleccionar lista de bienes para donación *',
        name: 'request_goods_description',
      );

  String get request_goods_address => Intl.message(
        'Qué dirección de los productos a recibir *',
        name: 'request_goods_address',
      );

  String get request_goods_address_hint => Intl.message(
        'Los donantes utilizarán la dirección que se indica a continuación para enviar los artículos. Agregue detalles adicionales a los detalles de la solicitud, especifique la dirección solo aquí.',
        name: 'request_goods_address_hint',
      );

  String get request_goods_address_inputhint => Intl.message(
        'Solo dirección',
        name: 'request_goods_address_inputhint',
      );

  String get request_payment_description => Intl.message(
        'Detalles del pago*',
        name: 'request_payment_description',
      );

  String get request_payment_description_hint => Intl.message(
        'SevaX no procesa ningún pago, debe tener su propia dirección para el cobro de pagos, proporcione uno de los siguientes detalles de paypal, zelpay (o) ACH',
        name: 'request_payment_description_hint',
      );

  String get request_payment_description_inputhint => Intl.message(
        'Ejemplo: https://www.paypal.com/johndoe',
        name: 'request_payment_description_inputhint',
      );

  String get request_min_donation_hint => Intl.message(
        'Ex: \$ 10',
        name: 'request_min_donation_hint',
      );

  String get validation_error_target_donation_count => Intl.message(
        'Ingrese el número de donación objetivo necesaria',
        name: 'validation_error_target_donation_count',
      );

  String get validation_error_target_donation_count_negative => Intl.message(
        'Ingrese el número de donación objetivo necesaria',
        name: 'validation_error_target_donation_count_negative',
      );

  String get validation_error_target_donation_count_zero => Intl.message(
        'Ingrese el número de donación objetivo necesaria',
        name: 'validation_error_target_donation_count_zero',
      );

  String get validation_error_min_donation_count => Intl.message(
        'Ingrese el número mínimo de donación necesaria',
        name: 'validation_error_min_donation_count',
      );

  String get validation_error_min_donation_count_negative => Intl.message(
        'Ingrese el número mínimo de donación necesaria',
        name: 'validation_error_min_donation_count_negative',
      );

  String get validation_error_min_donation_count_zero => Intl.message(
        'Ingrese el número mínimo de donación necesaria',
        name: 'validation_error_min_donation_count_zero',
      );

  String get request_description_hint_cash => Intl.message(
        'Por ejemplo: especifique la causa de la recaudación de fondos y cualquier #hashtags',
        name: 'request_description_hint_cash',
      );

  String get demotion_from_admin_to_member => Intl.message(
        'Degradación de administrador a miembro',
        name: 'demotion_from_admin_to_member',
      );

  String get promotion_to_admin_from_member => Intl.message(
        'Promoción a administrador de miembro',
        name: 'promotion_to_admin_from_member',
      );

  String get feedback_one_to_many_offer => Intl.message(
        'Comentarios para la oferta uno a muchos',
        name: 'feedback_one_to_many_offer',
      );

  String get sure_to_cancel_one_to_many_offer => Intl.message(
        '¿Está seguro de que desea cancelar esta oferta de uno a varios?',
        name: 'sure_to_cancel_one_to_many_offer',
      );

  String get proceed_with_cancellation => Intl.message(
        'Haga clic en Aceptar para continuar con la cancelación, de lo contrario, presione cancelar',
        name: 'proceed_with_cancellation',
      );

  String get members_signed_up_advisory => Intl.message(
        'La gente ya se ha suscrito a la oferta. Cancelar la oferta resultaría en que estos usuarios recuperaran los SevaCredits. Haga clic en Aceptar para continuar con la cancelación. De lo contrario, presione cancelar.',
        name: 'members_signed_up_advisory',
      );

  String get notification_one_to_many_offer_canceled_title => Intl.message(
        'Se canceló una oferta de uno a varios a la que te registraste',
        name: 'notification_one_to_many_offer_canceled_title',
      );

  String get notification_one_to_many_offer_canceled_subtitle => Intl.message(
        'Te habías apuntado a una oferta de mierda. Debido a circunstancias imprevistas, *** name tuvo que cancelar esta oferta. Recibirá créditos por los SevaCredits no utilizados.',
        name: 'notification_one_to_many_offer_canceled_subtitle',
      );

  String get nearby_settings_title => Intl.message(
        'Distancia que estoy dispuesto a recorrer',
        name: 'nearby_settings_title',
      );

  String get nearby_settings_content => Intl.message(
        'Esto indica la distancia que el usuario está dispuesto a recorrer para completar una Solicitud de Banco de Tiempo o participar en un Proyecto.',
        name: 'nearby_settings_content',
      );

  String get amount => Intl.message(
        'Cantidad',
        name: 'amount',
      );

  String get only_images_types_allowed => Intl.message(
        'Solo se permiten tipos de imágenes, por ejemplo: jpg, png \'',
        name: 'only_images_types_allowed',
      );

  String get i_pledged_amount => Intl.message(
        'Me comprometo a donar esta cantidad',
        name: 'i_pledged_amount',
      );

  String get i_received_amount => Intl.message(
        'Reconozco que he recibido',
        name: 'i_received_amount',
      );

  String get acknowledge_desc_one => Intl.message(
        'Nota: Verifique la cantidad que ha recibido de',
        name: 'acknowledge_desc_one',
      );

  String get acknowledge_desc_two => Intl.message(
        'Este puede ser menor que el monto prometido debido a una tarifa de transacción. Si hay una discrepancia, envíe un mensaje',
        name: 'acknowledge_desc_two',
      );

  String get acknowledge_desc_donor_one => Intl.message(
        'Nota: asegúrese de que la cantidad que transfiera',
        name: 'acknowledge_desc_donor_one',
      );

  String get acknowledge_desc_donor_two => Intl.message(
        'coincide con el monto prometido anteriormente (sujeto a cualquier tarifa de transacción)',
        name: 'acknowledge_desc_donor_two',
      );

  String get acknowledge_received => Intl.message(
        'Reconozco que he recibido a continuación',
        name: 'acknowledge_received',
      );

  String get acknowledge_donated => Intl.message(
        'Reconozco que he donado a continuación',
        name: 'acknowledge_donated',
      );

  String get amount_pledged => Intl.message(
        'Monto comprometido',
        name: 'amount_pledged',
      );

  String get amount_received_from => Intl.message(
        'Cantidad recibida de',
        name: 'amount_received_from',
      );

  String get donations_received => Intl.message(
        'Donaciones recibidas',
        name: 'donations_received',
      );

  String get donations_requested => Intl.message(
        'Donación solicitada',
        name: 'donations_requested',
      );

  String get pledge_modified => Intl.message(
        'No se reconoció la cantidad prometida para la donación',
        name: 'pledge_modified',
      );

  String get donation_completed => Intl.message(
        'Donación completada',
        name: 'donation_completed',
      );

  String get donation_completed_desc => Intl.message(
        'Su donación se completó con éxito. Se le ha enviado un recibo por correo electrónico.',
        name: 'donation_completed_desc',
      );

  String get pledge_modified_by_donor => Intl.message(
        'El donante ha modificado el monto de la promesa',
        name: 'pledge_modified_by_donor',
      );

  String get has_cash_donation => Intl.message(
        'Tiene una solicitud de donación en efectivo',
        name: 'has_cash_donation',
      );

  String get has_goods_donation => Intl.message(
        'Ha solicitado donación de bienes',
        name: 'has_goods_donation',
      );

  String get cash_donation_invite => Intl.message(
        'Tiene una solicitud de donación en efectivo. Toca para donar cualquier cantidad que puedas',
        name: 'cash_donation_invite',
      );

  String get goods_donation_invite => Intl.message(
        'Tiene una solicitud de donación de bienes específicos. Puede tocar para donar cualquier bien que pueda',
        name: 'goods_donation_invite',
      );

  String get failed_load_image => Intl.message(
        'No se pudo cargar la imagen. Prueba una imagen diferente',
        name: 'failed_load_image',
      );

  String get request_updated => Intl.message(
        'Solicitud actualizada',
        name: 'request_updated',
      );

  String get demoted => Intl.message(
        'DEMOTADO',
        name: 'demoted',
      );

  String get promoted => Intl.message(
        'PROMOVIDO',
        name: 'promoted',
      );

  String get seva_coins_debited => Intl.message(
        'Seva Coins debitado',
        name: 'seva_coins_debited',
      );

  String get debited => Intl.message(
        'Debitado',
        name: 'debited',
      );

  String get member_reported_title => Intl.message(
        'Miembro informado',
        name: 'member_reported_title',
      );

  String get cannot_be_deleted => Intl.message(
        'no se puede borrar',
        name: 'cannot_be_deleted',
      );

  String get cannot_be_deleted_desc => Intl.message(
        'Su solicitud para eliminar ** requestData.entityTitle no se puede completar en este momento. Hay transacciones pendientes. Toque aquí para ver los detalles.',
        name: 'cannot_be_deleted_desc',
      );

  String get delete_request_success => Intl.message(
        '** requestTitle que solicitaste eliminar se ha eliminado correctamente.',
        name: 'delete_request_success',
      );

  String get community => Intl.message(
        'Comunidad',
        name: 'community',
      );

  String get stock_images => Intl.message(
        'Imágenes de archivo',
        name: 'stock_images',
      );

  String get choose_image => Intl.message(
        'Elegir imagen',
        name: 'choose_image',
      );

  String get timebank_has_parent => Intl.message(
        'Timebank tiene padre',
        name: 'timebank_has_parent',
      );

  String get timebank_location_has_parent_hint_text => Intl.message(
        'Si su banco de tiempo está asociado con un banco de tiempo principal, seleccione a continuación',
        name: 'timebank_location_has_parent_hint_text',
      );

  String get select_parent_timebank => Intl.message(
        'Seleccionar banco de tiempo principal',
        name: 'select_parent_timebank',
      );

  String get look_for_existing_siblings => Intl.message(
        'El feed es visible para los siguientes bancos de tiempo',
        name: 'look_for_existing_siblings',
      );

  String get none => Intl.message(
        'Ninguna',
        name: 'none',
      );

  String get find_your_parent_timebank => Intl.message(
        'Encuentre su banco de tiempo para padres si es parte de',
        name: 'find_your_parent_timebank',
      );

  String get look_for_existing_timebank_title => Intl.message(
        'Buscando banco de tiempo existente',
        name: 'look_for_existing_timebank_title',
      );

  String get copied_to_clipboard => Intl.message(
        'Copiado al portapapeles',
        name: 'copied_to_clipboard',
      );

  String get delete_comment_msg => Intl.message(
        '¿Seguro que quieres eliminar el comentario?',
        name: 'delete_comment_msg',
      );

  String get goods_modified_by_donor => Intl.message(
        'El donante ha modificado bienes',
        name: 'goods_modified_by_donor',
      );

  String get goods_modified_by_creator => Intl.message(
        'No se reconocieron sus bienes para la donación',
        name: 'goods_modified_by_creator',
      );

  String get amount_modified_by_creator_desc => Intl.message(
        'La cantidad que prometió para esta donación es diferente de la cantidad reconocida por el creador. Toque para cambiar el monto de su contribución.',
        name: 'amount_modified_by_creator_desc',
      );

  String get goods_modified_by_creator_desc => Intl.message(
        'Los bienes que donó para esta donación son diferentes de los bienes reconocidos por el creador. Toque para cambiar los detalles de su mercancía.',
        name: 'goods_modified_by_creator_desc',
      );

  String get amount_modified_by_donor_desc => Intl.message(
        'La cantidad que reconoció por esta donación es diferente de la cantidad confirmada por el Donante. Toque para cambiar la cantidad de confirmación.',
        name: 'amount_modified_by_donor_desc',
      );

  String get goods_modified_by_donor_desc => Intl.message(
        'Los bienes que reconoció para esta donación son diferentes de los bienes confirmados por el Donante. Toque para cambiar los productos de confirmación.',
        name: 'goods_modified_by_donor_desc',
      );

  String get imageurl_alert => Intl.message(
        'Alerta de URL de imagen web',
        name: 'imageurl_alert',
      );

  String get image_url_alert_desc => Intl.message(
        'Agregue una URL de imagen para continuar',
        name: 'image_url_alert_desc',
      );

  String get enter_valid_link => Intl.message(
        'Ingrese un enlace de pago válido',
        name: 'enter_valid_link',
      );

  String get target_amount_less_than_min_amount => Intl.message(
        'La cantidad mínima no puede ser mayor que la cantidad objetivo',
        name: 'target_amount_less_than_min_amount',
      );

  String get failed_load_image_title => Intl.message(
        'Falló al cargar',
        name: 'failed_load_image_title',
      );

  String get image_url_hint => Intl.message(
        'Agregar URL de imagen, por ejemplo: https://www.sevaexchange.com/sevalogo.png',
        name: 'image_url_hint',
      );

  String get request_details => Intl.message(
        'Pedir detalles',
        name: 'request_details',
      );

  String get skip_for_now => Intl.message(
        'Saltar por ahora',
        name: 'skip_for_now',
      );

  String get would_like_to_donate => Intl.message(
        '¿Le gustaría donar para esta solicitud?',
        name: 'would_like_to_donate',
      );

  String get total_goods_recevied => Intl.message(
        'Total de bienes recibidos',
        name: 'total_goods_recevied',
      );

  String get total_amount_raised => Intl.message(
        'Cantidad total recaudada',
        name: 'total_amount_raised',
      );

  String get by_accepting_group_join => Intl.message(
        'Al aceptar, se le agregará a',
        name: 'by_accepting_group_join',
      );

  String get group_join => Intl.message(
        'Unirse al grupo',
        name: 'group_join',
      );

  String get request_payment_descriptionZelle_inputhint => Intl.message(
        'ID de Zellepay (teléfono o correo electrónico)',
        name: 'request_payment_descriptionZelle_inputhint',
      );

  String get request_payment_ach_bank_name => Intl.message(
        'Nombre del banco*',
        name: 'request_payment_ach_bank_name',
      );

  String get request_payment_ach_bank_address => Intl.message(
        'Dirección del banco *',
        name: 'request_payment_ach_bank_address',
      );

  String get request_payment_ach_routing_number => Intl.message(
        'Número de ruta *',
        name: 'request_payment_ach_routing_number',
      );

  String get request_payment_ach_account_no => Intl.message(
        'Número de cuenta*',
        name: 'request_payment_ach_account_no',
      );

  String get enter_valid_bank_address => Intl.message(
        'Ingrese la dirección del banco',
        name: 'enter_valid_bank_address',
      );

  String get enter_valid_bank_name => Intl.message(
        'Ingrese el nombre del banco',
        name: 'enter_valid_bank_name',
      );

  String get enter_valid_account_number => Intl.message(
        'Ingrese el número de cuenta',
        name: 'enter_valid_account_number',
      );

  String get enter_valid_routing_number => Intl.message(
        'Ingrese el número de ruta',
        name: 'enter_valid_routing_number',
      );

  String get request_paymenttype_zellepay => Intl.message(
        'ZellePay',
        name: 'request_paymenttype_zellepay',
      );

  String get request_paymenttype_paypal => Intl.message(
        'PayPal',
        name: 'request_paymenttype_paypal',
      );

  String get request_paymenttype_ach => Intl.message(
        'ACH',
        name: 'request_paymenttype_ach',
      );
}

class ArbifyLocalizationsDelegate extends LocalizationsDelegate<S> {
  const ArbifyLocalizationsDelegate();

  List<Locale> get supportedLocales => [
        Locale.fromSubtags(languageCode: 'es'),
        Locale.fromSubtags(languageCode: 'pt'),
        Locale.fromSubtags(languageCode: 'sn'),
        Locale.fromSubtags(languageCode: 'zh'),
        Locale.fromSubtags(languageCode: 'zh'),
        Locale.fromSubtags(languageCode: 'af'),
        Locale.fromSubtags(languageCode: 'sw'),
        Locale.fromSubtags(languageCode: 'en'),
        Locale.fromSubtags(languageCode: 'fr'),
  ];

  @override
  bool isSupported(Locale locale) => [
        'es',
        'pt',
        'sn',
        'zh',
        'zh',
        'af',
        'sw',
        'en',
        'fr',
      ].contains(locale.languageCode);

  @override
  Future<S> load(Locale locale) => S.load(locale);

  @override
  bool shouldReload(ArbifyLocalizationsDelegate old) => false;
}
