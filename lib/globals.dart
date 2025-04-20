library sevax.globals;

//String? sevaUserID;

String appTitle = 'Seva X';
bool isMobile = true;
//USER PROFILE INFO
//String? bio;

//AVATAR AND IMAGE STUFF
String? posterAvatarURL;

String? timebankAvatarURL;
String? timebankCoverURL;

String? projectsAvtaarURL;
String? projectsCoverURL;

String? campaignAvatarURL;
String? messagingRoomImageUrl;

String? newsImageURL;
String? newsDocumentURL;
String? newsDocumentName;
String? userExitReason;
String? webImageUrl;

//DYNAMIC LISTS
List<dynamic> interests = [];
List<dynamic> skills = [];
//List<dynamic> userTimebanksCampaigns = [];
List<dynamic> tempList = [];

List<dynamic> addedMembersId = [];
List<dynamic> addedMembersFullname = [];
List<dynamic> addedMembersPhotoURL = [];

List<dynamic> currentTimebankMembersEmail = [];
List<dynamic> currentTimebankMembersFullname = [];
List<dynamic> currentTimebankMembersPhotoURL = [];

List<dynamic> currentCampaignMembersEmail = [];
List<dynamic> currentCampaignMembersFullname = [];
List<dynamic> currentCampaignMembersPhotoURL = [];

//FLOW CONTROL PROPERTIES (tasks)
int orCreateSelector = 0;
int? orTaskSelector;

dynamic onLoadResult;

bool isSame = false;
bool isFromOnBoarding = false;

bool userRecordExists = false;
bool isBillingDetailsProvided = false;

// Google User Details
//String? photoURL;
//String? email;
//String? fullname;
String? phoneNumber;
String? profileLastUpdate;
Object? metaData;
Type? typeRuntimeType;
bool? isEmailVerified;
String? providerID;

String? requestPhotoURL;

String? tempDescriptionRequest;

// TIMEBANK
String? currentTimebankName;
String? currentTimebankMission;
String? currentTimebankNumber;
String? currentTimebankEmail;
String? currentTimebankAvatar;
String? currentTimebankAddress;
String? currentTimebankCreator;
String? currentTimebankOwnerFullname;
String? currentTimebankOwnerPhotoURL;
String? currentTimebankOwnerEmail;
List<dynamic> currentTimebankMembers = [];
int? currentCreatedTimeStamp;

dynamic currentTimebank;

//CAMPAIGN
String? currentCampaignName;
String? currentCampaignMission;
String? currentCampaignNumber;
String? currentCampaignEmail;
String? currentCampaignAvatar;
String? currentCampaignAddress;
String? currentCampaignCreator;
String? currentCampaignOwnerFullname;
String? currentCampaignOwnerPhotoURL;
String? currentCampaignOwnerEmail;
List<dynamic> currentCampaignMembers = [];
int? currentCampaignCreatedTimeStamp;

dynamic currentCampaign;
bool isNearme = false;
String content = 'All';
String? currentVersionNumber;

int sharedValue = 0;
