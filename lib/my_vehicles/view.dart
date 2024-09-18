import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:luvpark_get/custom_widgets/app_color.dart';
import 'package:luvpark_get/custom_widgets/custom_appbar.dart';
import 'package:luvpark_get/custom_widgets/no_data_found.dart';
import 'package:luvpark_get/custom_widgets/no_internet.dart';
import 'package:luvpark_get/custom_widgets/page_loader.dart';

import '../custom_widgets/custom_text.dart';
import 'controller.dart';

class MyVehicles extends GetView<MyVehiclesController> {
  const MyVehicles({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bodyColor,
      appBar: CustomAppbar(
        title: "My Vehicles",
        bgColor: AppColor.primaryColor,
        textColor: Colors.white,
        titleColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(
            Iconsax.add,
            color: Colors.white,
          ),
          onPressed: () async {
            controller.getVehicleDropDown();
          }),
      body: Obx(
        () => controller.isLoadingPage.value
            ? const PageLoader()
            : !controller.isNetConn.value
                ? NoInternetConnected(
                    onTap: controller.onRefresh,
                  )
                : Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: RefreshIndicator(
                      onRefresh: controller.onRefresh,
                      child: controller.vehicleData.isEmpty
                          ? const NoDataFound()
                          : StretchingOverscrollIndicator(
                              axisDirection: AxisDirection.down,
                              child: ListView.builder(
                                itemCount: controller.vehicleData.length,
                                itemBuilder: (context, index) {
                                  // String yowo =
                                  //     "/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAAQDAwQDAwQEAwQFBAQFBgoHBgYGBg0J CggKDw0QEA8NDw4RExgUERIXEg4PFRwVFxkZGxsbEBQdHx0aHxgaGxr/2wBDAQQF BQYFBgwHBwwaEQ8RGhoaGhoaGhoaGhoaGhoaGhoaGhoaGhoaGhoaGhoaGhoaGhoa GhoaGhoaGhoaGhoaGhr/wAARCAEAAQADASIAAhEBAxEB/8QAHQABAAIDAQEBAQAA AAAAAAAAAAcIBAYJBQEDAv/EAEoQAAEEAQIDBAUFCgsJAAAAAAABAgMEBQYHCBES EyExQRQiUWGzGHGBlNMVFjI3U1R1kaHSJzVCcnSChLGytME2UlViZJXD0eL/xAAb AQEAAgMBAQAAAAAAAAAAAAAAAwQFBgcCAf/EAC4RAAIBAwMDAwQBBAMAAAAAAAAB AgMEEQUSITFBUQYTYRQicaHBgdHh8CNSkf/aAAwDAQACEQMRAD8Av8AAAAAAAAAA AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA AAAAAAQzvDrHcfS+Topt7p9uXxz6rpLL/Q3TrHIju5PVcnkTMfFI6kHOOE8fguWd xC1rKpOmqiXaWcfrwUk+Vjr1O51bCfVX/aHtaf4gd3dVpY+9jTlHK9h3SOr4+RzW Kvgir2hAuqe7VGd/SNn4zycNgd5tL7baXyWP1Kt1tmxfdOxK9VZE6Ohqf6GApVqk qm2dRpHaNR0qyt7P3rWyjUnxiOH369H2LN6xyWpKGgrOQ01Qbd1JHWifFVWPqR8i q3rb0808uZWbN8SW6OmrvoWoMJjsZa6EkSKxQkYqtXz75CWPlWbfflMv/wBvX/2V 94gdycJuVncNe0ytpYalN8MvbwdmvUr+aFy6rR27qdTnwat6e0qr7/sX1ktry90k 8rjhdcYPfo8Ue42UuQUsbjcVcuTuRsUENKR75F9iIjyxm0upNY5vA5C3uXimYSzF Y5Qt7LskWFGIvUqKq+fMqTw5fjm01/aP8vIWD4rNUWcFoKtjaL1idmrfYTPT8i1q ue36T5bVZ+3KtOTeOxPrlhayv6Wl2tCMHUw93OVy845x0R42v+LHH4uzNR0HQbmZ I1VHXbDlbX/qInrPIrbxA7saouLWwU6rKqc0gxuLSRU/Y9SFVXoaq+xFU6J7O6Mo 6L0Hhq1KGNtmxVjsXJkb600z2oqqq+7nyT5iKlKvdzeZYS8F/U7bSfTNpCSt1UnJ 4W7nOFlt/wBkir9zcnfbAxLbyaZutXb3rJZwrOj4Zmae4tdW0JUTUVLH5muvisTV ryfrT1S6apzKJcS+jqWktwmyYiFtetlaiW3RRpya2TqVj1RP2klenWto74zb/JS0 a90zXa7tbizhFtNpx+Ovhp9y223W6OB3Nxj7On5nMsQ8ks05k6ZYVX2p5ovk5O4g fWu9+7Oj796S/putSxTLckVe1Yx8nZvb1KjPX6yEtpNUWNJbiYG/WkVsUlplay3y fDI9GuRS4nEoiLs3qH3LX+PGe41p3FByUsOPjuVa2l2ui6vTt5UlVp1mkt2cx5w8 YxnquvVFfPlZ68/N8J9Vf9obNoDitytrUlWprqvj4MTZVI3Wa0bmLA5fB7uarzYR Ztftk7cvE6tix6qmZx0EE9BFXk16qr+qNf5xHM8MleWWGxG+KaNyskje3krHIvJU VPahQ+ouIYm5cM3J6Lol06ttGjFSjw8cNZWU1z/rWGdJNfZPN4zRuSyGjKaZLMxx NdUgRnWkiq5Ofcipz7uZVzMcSu52nrnoeew2PxlrpR/ZWsfLG7kvzvNx4ZN3vuhD ForUc/O3Azni5pF75Y2+MK+9vinuNY4w/wDa7TX6Ol+Khfr1XOj71OTXwabpGnUr TU3pd7bxnnMlJ5zhLjHOMP8A9Tye5oDendfWWWxLodOV7GCmuxxWbkGPkRjI+tEe qPV/LuQ/fcTePdXRWczTm6bhZp+tcfHVvT4+R0b4urkxVejuRKnD2iJs3pRE8Owk +M8yN+E/gg1f+j3f3oSKFT2N295xn9dDHyvLJax9P9HDZu2Y5/743dev6wVo+Vnr v82wv1V/2h+qcVW4Tk9XHYz6hL++QHL4P+ZTphoJE+8fTPcn8U1fhNKds61w2vca wbVr1PSdEp05/RxnubXdYws/JUlOLTXUMiJPRwqp/uOqyNX4huuk+LyCxZZBrTBr Tjf3ek0XrI1vvcxe8sHqrRuF1ni58dqChBagmYrep0adbF8nMd4tVPahzZylB2Ly d6hKvU+pYkrqvtVjlbzPdeVxatPflMraRQ0T1FTqQVqqco46N9+6f9OjR05xOWpZ 3HV8jiLMdylZYj4Zo15te1fNCLN5NXbiaZu4xNutP/dmpJDItp3orplY/miNTuVC MuEDU9l0+f01PIr6sUbL1dFX8BVXokT9fIsLuBrOloDSl/PZLk5tdnKKPzmlXuZG nvVS/Goq9Dfnb/g0utYy0jWPpvbVbnhPvu6Zx3/leCp9rio3DpWJa1yhia1mJysk ikpSNcxyeSorz+PlZ68/N8J9Vf8AaGrbc6RyO9W5E0uYc58E063cxO31URir+Anv d4IbjxLbUM0plYdS6fqthw19UjsRRM5Mrzoncv8ANeYndcypuopPCOlO20Gne07C pQgqklnhcJ+OvV84+F8on/ZDdtm6WBmW6yKrnaLkZdgjX1VRfwZG8+/pUlU5rbea 3u7earpZuhzkbGvZ2YfKeFfw2HRjCZqlqLEUsriJm2KNyJssMieDmr4GTs7j3oYl 1Rz/ANT6KtKufcor/in0+H3j/K+PweiAC+acD4p9Ib3h0nuTqTKUV26zzcRjm1lZ ZZ6UsKvkVy9/NGqvgR1JOEcpZ/Bcs7eF1WVOdRU0+8s4/RSfVPfqjO/pGz8Z5N+w WzOmNyNM5HI6k9OWzXvOgjWta7NOjoav+p5q8KWvlVVdNiHOX/q3fuHu6e2H3h0g 2wmls/SxST98jYL7ulyp4KqLGYClRqRqbp020do1HVLOvZeza3sYT4xLL7deifUk /wCSfoD25j6//wDJX7iA22we2mew1HTSWkiuU3zTekz9qvNH8kLh6xxmpL+grVHT V9tPUr60TIrKv6UbKit616uS+PJSsWb4cd09SXfTNQZahlLSNRjZbGQe9WtTy72F 26ox27adPnyjVvT2q1nX9++vltWVtk3zxw+mMGncOPdvNpr+0/5eQsLxVaWs53QF fJUWLK/DWu3lYn5FzVa9fo7iIsfwwbj4q7Bdxl7GU7ldyOimhvPY+NfaiowsbtJp 7WWGwORp7m5RmZszWFWFyzdryhViIrVVUTz5ni2pzdOVGcWs9yfXb61jf0tUta8J unhbcvL5ee2OjOeyp1tVPaiodFNndZUNaaBw9qnMx9mtVir3IUXm6KZjUa5HJ7+X NCKtf8J2PytqW9oS+zDySKquo2Gq+vz/AORU72fQRWzh+3Y0vcWzgIFZKnd6Rjco 2Ny/tYpHSjXtJvMcp+C/qdzpPqa0hFXCpzi8rdx1WGn/AHTL0FEuJfWFLVu4jY8R PHZrYqmlR00a82uk6le9EVPZ4Gbc2332zsK1MmucsQO7ljsZpnR8QzNPcJerb8jV 1FeoYaunikblsy/Ry5NJK9Srcx2Rg1+Sjo1lpmhV3dXF5CTSaSj89fLb7EcbR6Ws au3EwNGvGroorbLVp3PuZDGrXO5lwuJP8Teovnr/AB4zYNutr8DtljX1cBC59ibk tm5MvVLOqe1fJE8moQVrjZnd7WV2/DkdQ1reHktvlr1Jcg5I0b1KrObUj8kPcaM7 eg4qOXLx2K1bVLbWtXp13VVOnRaa3ZzLnLxjOOi69EYvBz/HOrP6LW/xvM7ib2e7 ptb6bhVOXfloI05d35f6P5XuNewXDpurpe2+3p3M0cXYe3s3yVsg9ivb7F9QtJoz G5eto3GY/Wk8eRyza3Z3pefW2V3NefknNFQUaTqUfZqRax3Pmq6jTstVWqWdeM1L CcU3nCXOeMY44fZ4ObVS3PQtw2qUz61mB7ZIpY3cnRuReaKi+1CQt19yk3Mi0ret M7PKU6Mle+xG8m9p180e33OQkzWvChmnahtzaIsY9uHncskMNmVzHQc/FngvNpr3 yUNe/lcN9bd+4Y90LiCcNrw/4N0Ws6JczpXUq0VKKeMvDW5YafH+tZLJcPX4nNK/ 0eT4zzI33XltBq/9Hu/vQz9p9NXdG7fYPBZZ0Tr1GJ7Jlid1M5rI53cv0kM7i7Rb sa1y+ZiZqis7Ttq099ehLdexiRdXNjXNbGZmbnC3UVFttY/Ry23jb3GtVK868YQj Pcm8/ct+eMLx5KkS+D/mU6X6Cc37x9M+s1eWJq/CaVI+SVrr87wf1qT7M/v5KGvv +IYf63J9mY62jXt237beTedeq6TrdOnD6yMNrb85ysfBbXVWtsHozGT39QZGvVhi Yrul0ido9fJrW+Kqpzbyl92Uyd6/KnS+3YksKnsV7ldyJvZwk65keiy38I33usSO /wDGbrpThErVrDJ9Z5tbzGd61aMaxsd8717z3XjcXTS2YSK+k19E9O06klde5KWO ifbsl/Xq2Y/CFpa1Eue1LMzs607GUayr/LVruuRyfTyNE4iNyH6+1lHgsG5bGKxc ywwti7/SLS+q5yf4Gkzbmbabh5DIVaO2WXgwOloKDKzaENp1ZEX1uruYnsIih4Vd wIZI5YJ8RFJGqOY9l16Kip4Kiow+VYVY01RhF4XV+T7YXWnVtQlq1zXgpSX2xy8x 4x93HXHjyz9Mfww7k1o+qnkMfQdIiLI1mRljX5ndCGRPwy7m2olit5qjPCvjHLlJ 3t/UrSwWzun9d6foZSLcvMNy8skzFpvSbtVYzkvUiryTz5Gw7j4zUeX0hfqaHvNx uckWP0ew5/T0cnoru/kvi3mWI2dJ092H+MmGq+p9QjeeyqlJrKW/b9vPfPXC/g57 6u0lk9EagtYPPRJFdr8nKrF5skaqc0cxfNFJx4X90fuRk/vNzMvTSvv68c9690cy +Mf9fxQw8xw1bnagvPvZ3J47I3ZERrprGQe9yongnewwW8KWv2OR0c+Ia5qoqKl1 /wC4UKdOvSqb4Qf+DcLy/wBI1KwdtdXMNzXVdFLysrz+sou+CGNnNI7k6ayd924m fTLY59ZrKzFtunWORHd697U8iZzP05OcctY/Jxe8t4WtZ04VFUSxzHOP34AAJCmA AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA AAAAAAAAAAAAf//Z";
                                  String removeInvalidCharacters(String input) {
                                    // Define a regex pattern for valid Base64 characters
                                    final RegExp validChars =
                                        RegExp(r'[^A-Za-z0-9+/=]');

                                    // Replace all invalid characters with an empty string
                                    return input.replaceAll(validChars, '');
                                  }

                                  // return controller.vehicleData[index]
                                  //             ["image"] ==
                                  //         null
                                  //     ? Container(
                                  //         height: 50,
                                  //         width: 100,
                                  //         child: Image(
                                  //             image: AssetImage(
                                  //                 "assets/images/mo_image.png")),
                                  //       )
                                  //     : Base64ImageExample(
                                  //         base64String: removeInvalidCharacters(
                                  //           controller.vehicleData[index]
                                  //               ["image"],
                                  //         ),
                                  //       );

                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 5.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: ListTile(
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          CustomTitle(
                                            text: controller.vehicleData[index]
                                                ["vehicle_brand_name"],
                                            maxlines: 1,
                                          ),
                                        ],
                                      ),
                                      subtitle: CustomParagraph(
                                          text:
                                              'Plate number: ${controller.vehicleData[index]["vehicle_plate_no"]}',
                                          maxlines: 1),
                                      leading: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            fit: BoxFit.contain,
                                            image: controller.vehicleData[index]
                                                        ["image"] ==
                                                    null
                                                ? AssetImage(
                                                        "assets/images/no_image.png")
                                                    as ImageProvider
                                                : MemoryImage(
                                                    base64Decode(
                                                      removeInvalidCharacters(
                                                          controller
                                                                  .vehicleData[
                                                              index]["image"]),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                      trailing: Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFFF9D9D9),
                                        ),
                                        padding: const EdgeInsets.all(5.0),
                                        child: const Icon(
                                          Icons.delete,
                                          color: Color(0xFFD34949),
                                          size: 15.0,
                                        ),
                                      ),
                                      onTap: () {
                                        controller.onDeleteVehicle(
                                            controller.vehicleData[index]
                                                ["vehicle_plate_no"]);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ),
      ),
    );
  }
}
