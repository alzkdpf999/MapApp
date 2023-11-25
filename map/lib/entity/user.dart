class UserEntity{
  String? name,email,imgUrl,platForm;

  String? get  getName => name; // 유저이름
  String? get  getEmail => email; // 유저 이메일 
  String? get  getImgUrl => imgUrl; // 이미지 url
  String? get getPlatForm => platForm; // 어느 소셜 로그인인지
  UserEntity({required this.name, required this.email, required this.imgUrl,required this.platForm});



  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "imgUrl": imgUrl,
      "platform": platForm,
    };
  }
}