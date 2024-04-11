class Slider {
  final String imageUrl;
  final String title;
  final String description;

  Slider({
    required this.imageUrl,
    required this.title,
    required this.description,
  });
}

final slideList = [
  Slider(
    imageUrl: "assets/images/welcome_pay.png",
    title: "Welcome to LuvPay",
    description:
        "Welcome to LuvPay, your ultimate destination for stress-free parking! With LuvPay.",
  ),
  Slider(
    imageUrl: "assets/images/welcome_paybills.png",
    title: "Find",
    description:
        "Make payments for your utility expenses such as electricity, water, gas, broadband, landline, insurance, loans, and more.",
  ),
  Slider(
    imageUrl: "assets/images/parking.png",
    title: "Book",
    description:
        "Simplify your parking payments using Luvpay. Connect your preferred payment method, choose your parking spot, and complete the transaction right from your smartphone. No need for cash or cards—just a secure and effortless payment process with a few taps. Experience smooth and hassle-free parking with our convenient mobile wallet payment feature.",
  ),
];
