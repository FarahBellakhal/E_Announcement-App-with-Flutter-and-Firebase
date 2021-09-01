import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app_flutter/components/default_button.dart';
import 'package:e_commerce_app_flutter/exceptions/local_files_handling/image_picking_exceptions.dart';
import 'package:e_commerce_app_flutter/exceptions/local_files_handling/local_file_handling_exception.dart';
import 'package:e_commerce_app_flutter/models/Annonce.dart';
import 'package:e_commerce_app_flutter/screens/edit_item/provider_models/AnnonceDetails.dart';
import 'package:e_commerce_app_flutter/services/database/annonce_database_helper.dart';
import 'package:e_commerce_app_flutter/services/firestore_files_access/firestore_files_access_service.dart';
import 'package:e_commerce_app_flutter/services/local_files_access/local_files_access_service.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../size_config.dart';

class EditAnnonceForm extends StatefulWidget {
  final Annonce annonce;
  EditAnnonceForm({
    Key key,
    this.annonce,
  }) : super(key: key);

  @override
  _EditAnnonceFormState createState() => _EditAnnonceFormState();
}

class _EditAnnonceFormState extends State<EditAnnonceForm> {
  final _basicDetailsFormKey = GlobalKey<FormState>();
  final _describeAnnonceFormKey = GlobalKey<FormState>();
  final _tagStateKey = GlobalKey<TagsState>();

  final TextEditingController titleFieldController = TextEditingController();
  final TextEditingController variantFieldController = TextEditingController();
  final TextEditingController discountPriceFieldController =
      TextEditingController();
  final TextEditingController originalPriceFieldController =
      TextEditingController();
  final TextEditingController highlightsFieldController =
      TextEditingController();
  final TextEditingController desciptionFieldController =
      TextEditingController();
  final TextEditingController sellerFieldController = TextEditingController();

  bool newAnnonce = true;
  Annonce annonce;

  @override
  void dispose() {
    titleFieldController.dispose();
    //variantFieldController.dispose();
    discountPriceFieldController.dispose();
    originalPriceFieldController.dispose();
    highlightsFieldController.dispose();
    desciptionFieldController.dispose();
    sellerFieldController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.annonce == null) {
      annonce = Annonce(null);
      newAnnonce = true;
    } else {
      annonce = widget.annonce;
      newAnnonce = false;
      final annonceDetails =
          Provider.of<AnnonceDetails>(context, listen: false);
      annonceDetails.initialSelectedImages = widget.annonce.images
          .map((e) => CustomImage(imgType: ImageType.network, path: e))
          .toList();
      annonceDetails.initialAnnonceType = annonce.annonceType;
      annonceDetails.initSearchTags = annonce.searchTags ?? [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final column = Column(
      children: [
        buildBasicDetailsTile(context),
        SizedBox(height: getProportionateScreenHeight(10)),
        buildDescribeAnnonceTile(context),
        SizedBox(height: getProportionateScreenHeight(10)),
        buildUploadImagesTile(context),
        SizedBox(height: getProportionateScreenHeight(20)),
        buildAnnonceTypeDropdown(),
        SizedBox(height: getProportionateScreenHeight(20)),
        buildAnnonceSearchTagsTile(),
        SizedBox(height: getProportionateScreenHeight(80)),
        DefaultButton(
            text: "Save Announcement",
            press: () {
              saveAnnonceButtonCallback(context);
            }),
        SizedBox(height: getProportionateScreenHeight(10)),
      ],
    );
    if (newAnnonce == false) {
      titleFieldController.text = annonce.title;
     variantFieldController.text = annonce.variant;
      discountPriceFieldController.text = annonce.discountPrice.toString();
      originalPriceFieldController.text = annonce.originalPrice.toString();
      highlightsFieldController.text = annonce.highlights;
      desciptionFieldController.text = annonce.description;
      sellerFieldController.text = annonce.seller;
    }
    return column;
  }

  Widget buildAnnonceSearchTags() {
    return Consumer<AnnonceDetails>(
      builder: (context, annonceDetails, child) {
        return Tags(
          key: _tagStateKey,
          horizontalScroll: true,
          heightHorizontalScroll: getProportionateScreenHeight(80),
          textField: TagsTextField(
            lowerCase: true,
            width: getProportionateScreenWidth(120),
            constraintSuggestion: true,
            hintText: "Add search tag",
            keyboardType: TextInputType.name,
            onSubmitted: (String str) {
              annonceDetails.addSearchTag(str.toLowerCase());
            },
          ),
          itemCount: annonceDetails.searchTags.length,
          itemBuilder: (index) {
            final item = annonceDetails.searchTags[index];
            return ItemTags(
              index: index,
              title: item,
              active: true,
              activeColor: kPrimaryColor,
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              alignment: MainAxisAlignment.spaceBetween,
              removeButton: ItemTagsRemoveButton(
                backgroundColor: Colors.white,
                color: kTextColor,
                onRemoved: () {
                  annonceDetails.removeSearchTag(index: index);
                  return true;
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget buildBasicDetailsTile(BuildContext context) {
    return Form(
      key: _basicDetailsFormKey,
      child: ExpansionTile(
        maintainState: true,
        title: Text(
          "Basic Details",
          style: Theme.of(context).textTheme.headline6,
        ),
        leading: Icon(
          Icons.shop,
        ),
        childrenPadding:
            EdgeInsets.symmetric(vertical: getProportionateScreenHeight(20)),
        children: [
          buildTitleField(),
          SizedBox(height: getProportionateScreenHeight(20)),
         buildVariantField(),
         SizedBox(height: getProportionateScreenHeight(20)),
          buildOriginalPriceField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildDiscountPriceField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildSellerField(),
          SizedBox(height: getProportionateScreenHeight(20)),
        ],
      ),
    );
  }

  bool validateBasicDetailsForm() {
    if (_basicDetailsFormKey.currentState.validate()) {
      _basicDetailsFormKey.currentState.save();
      annonce.title = titleFieldController.text;
      annonce.variant = variantFieldController.text;
      annonce.originalPrice = double.parse(originalPriceFieldController.text);
      annonce.discountPrice = double.parse(discountPriceFieldController.text);
      annonce.seller = sellerFieldController.text;
      return true;
    }
    return false;
  }

  Widget buildDescribeAnnonceTile(BuildContext context) {
    return Form(
      key: _describeAnnonceFormKey,
      child: ExpansionTile(
        maintainState: true,
        title: Text(
          "Describe Item",
          style: Theme.of(context).textTheme.headline6,
        ),
        leading: Icon(
          Icons.description,
        ),
        childrenPadding:
            EdgeInsets.symmetric(vertical: getProportionateScreenHeight(20)),
        children: [
          buildHighlightsField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildDescriptionField(),
          SizedBox(height: getProportionateScreenHeight(20)),
        ],
      ),
    );
  }

  bool validateDescribeAnnonceForm() {
    if (_describeAnnonceFormKey.currentState.validate()) {
      _describeAnnonceFormKey.currentState.save();
      annonce.highlights = highlightsFieldController.text;
      annonce.description = desciptionFieldController.text;
      return true;
    }
    return false;
  }

  Widget buildAnnonceTypeDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: kTextColor, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
      child: Consumer<AnnonceDetails>(
        builder: (context, annonceDetails, child) {
          return DropdownButton(
            value: annonceDetails.annonceType,
            items: AnnonceType.values
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      EnumToString.convertToString(e),
                    ),
                  ),
                )
                .toList(),
            hint: Text(
              "Chose Announcement Type",
            ),
            style: TextStyle(
              color: kTextColor,
              fontSize: 16,
            ),
            onChanged: (value) {
              annonceDetails.annonceType = value;
            },
            elevation: 0,
            underline: SizedBox(width: 0, height: 0),
          );
        },
      ),
    );
  }

  Widget buildAnnonceSearchTagsTile() {
    return ExpansionTile(
      title: Text(
        "Search Tags",
        style: Theme.of(context).textTheme.headline6,
      ),
      leading: Icon(Icons.check_circle_sharp),
      childrenPadding:
          EdgeInsets.symmetric(vertical: getProportionateScreenHeight(20)),
      children: [
        Text("Your announcement will be searched for this Tags"),
        SizedBox(height: getProportionateScreenHeight(15)),
        buildAnnonceSearchTags(),
      ],
    );
  }

  Widget buildUploadImagesTile(BuildContext context) {
    return ExpansionTile(
      title: Text(
        "Upload Images",
        style: Theme.of(context).textTheme.headline6,
      ),
      leading: Icon(Icons.image),
      childrenPadding:
          EdgeInsets.symmetric(vertical: getProportionateScreenHeight(20)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: IconButton(
              icon: Icon(
                Icons.add_a_photo,
              ),
              color: kTextColor,
              onPressed: () {
                addImageButtonCallback();
              }),
        ),
        Consumer<AnnonceDetails>(
          builder: (context, annonceDetails, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(
                  annonceDetails.selectedImages.length,
                  (index) => SizedBox(
                    width: 80,
                    height: 80,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: GestureDetector(
                        onTap: () {
                          addImageButtonCallback(index: index);
                        },
                        child: annonceDetails.selectedImages[index].imgType ==
                                ImageType.local
                            ? Image.memory(
                                File(annonceDetails.selectedImages[index].path)
                                    .readAsBytesSync())
                            : Image.network(
                                annonceDetails.selectedImages[index].path),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget buildTitleField() {
    return TextFormField(
      controller: titleFieldController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: "Title",
        labelText: "Title",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (titleFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildVariantField() {
    return TextFormField(
      controller: variantFieldController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: "Place",
        labelText: "Place",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (variantFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildHighlightsField() {
    return TextFormField(
      controller: highlightsFieldController,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        hintText:
            "Phone Number",
        labelText: "Phone Number",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (highlightsFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      maxLines: null,
    );
  }

  Widget buildDescriptionField() {
    return TextFormField(
      controller: desciptionFieldController,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        hintText:
            "Description.",
        labelText: "Description",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (desciptionFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      maxLines: null,
    );
  }

  Widget buildSellerField() {
    return TextFormField(
      controller: sellerFieldController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: "Uploaded by",
        labelText: "Seller",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (sellerFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildOriginalPriceField() {
    return TextFormField(
      controller: originalPriceFieldController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: "Price",
        labelText: "Original Price (in DT)",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (originalPriceFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildDiscountPriceField() {
    return TextFormField(
      controller: discountPriceFieldController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: "Discount",
        labelText: "Discount Price (in DT)",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (discountPriceFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Future<void> saveAnnonceButtonCallback(BuildContext context) async {
    if (validateBasicDetailsForm() == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erros in Basic Details Form"),
        ),
      );
      return;
    }
    if (validateDescribeAnnonceForm() == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Errors in Describe Announcement Form"),
        ),
      );
      return;
    }
    final annonceDetails = Provider.of<AnnonceDetails>(context, listen: false);
    if (annonceDetails.selectedImages.length < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Upload atleast One Image of Announcement"),
        ),
      );
      return;
    }
    if (annonceDetails.annonceType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select item Type"),
        ),
      );
      return;
    }
    if (annonceDetails.searchTags.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Add atleast 3 search tags"),
        ),
      );
      return;
    }
    String annonceId;
    String snackbarMessage;
    try {
      annonce.annonceType = annonceDetails.annonceType;
      annonce.searchTags = annonceDetails.searchTags;
      final productUploadFuture = newAnnonce
          ? AnnonceDatabaseHelper().addUsersAnnonce(annonce)
          : AnnonceDatabaseHelper().updateUsersAnnonce(annonce);
      productUploadFuture.then((value) {
        annonceId = value;
      });
      await showDialog(
        context: context,
        builder: (context) {
          return FutureProgressDialog(
            productUploadFuture,
            message:
                Text(newAnnonce ? "Uploading Announcement" : "Updating Announcement"),
          );
        },
      );
      if (annonceId != null) {
        snackbarMessage = "Announcement Info updated successfully";
      } else {
        throw "Couldn't update Announcement info due to some unknown issue";
      }
    } on FirebaseException catch (e) {
      Logger().w("Firebase Exception: $e");
      snackbarMessage = "Something went wrong";
    } catch (e) {
      Logger().w("Unknown Exception: $e");
      snackbarMessage = e.toString();
    } finally {
      Logger().i(snackbarMessage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(snackbarMessage),
        ),
      );
    }
    if (annonceId == null) return;
    bool allImagesUploaded = false;
    try {
      allImagesUploaded = await uploadAnnonceImages(annonceId);
      if (allImagesUploaded == true) {
        snackbarMessage = "All images uploaded successfully";
      } else {
        throw "Some images couldn't be uploaded, please try again";
      }
    } on FirebaseException catch (e) {
      Logger().w("Firebase Exception: $e");
      snackbarMessage = "Something went wrong";
    } catch (e) {
      Logger().w("Unknown Exception: $e");
      snackbarMessage = "Something went wrong";
    } finally {
      Logger().i(snackbarMessage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(snackbarMessage),
        ),
      );
    }
    List<String> downloadUrls = annonceDetails.selectedImages
        .map((e) => e.imgType == ImageType.network ? e.path : null)
        .toList();
    bool annonceFinalizeUpdate = false;
    try {
      final updateAnnonceFuture =
          AnnonceDatabaseHelper().updateAnnoncesImages(annonceId, downloadUrls);
      annonceFinalizeUpdate = await showDialog(
        context: context,
        builder: (context) {
          return FutureProgressDialog(
            updateAnnonceFuture,
            message: Text("Saving Announcement"),
          );
        },
      );
      if (annonceFinalizeUpdate == true) {
        snackbarMessage = "Announcement uploaded successfully";
      } else {
        throw "Couldn't upload Announcement properly, please retry";
      }
    } on FirebaseException catch (e) {
      Logger().w("Firebase Exception: $e");
      snackbarMessage = "Something went wrong";
    } catch (e) {
      Logger().w("Unknown Exception: $e");
      snackbarMessage = e.toString();
    } finally {
      Logger().i(snackbarMessage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(snackbarMessage),
        ),
      );
    }
    Navigator.pop(context);
  }

  Future<bool> uploadAnnonceImages(String annonceId) async {
    bool allImagesUpdated = true;
    final annonceDetails = Provider.of<AnnonceDetails>(context, listen: false);
    for (int i = 0; i < annonceDetails.selectedImages.length; i++) {
      if (annonceDetails.selectedImages[i].imgType == ImageType.local) {
        print("Image being uploaded: " + annonceDetails.selectedImages[i].path);
        String downloadUrl;
        try {
          final imgUploadFuture = FirestoreFilesAccess().uploadFileToPath(
              File(annonceDetails.selectedImages[i].path),
              AnnonceDatabaseHelper().getPathForAnnonceImage(annonceId, i));
          downloadUrl = await showDialog(
            context: context,
            builder: (context) {
              return FutureProgressDialog(
                imgUploadFuture,
                message: Text(
                    "Uploading Images ${i + 1}/${annonceDetails.selectedImages.length}"),
              );
            },
          );
        } on FirebaseException catch (e) {
          Logger().w("Firebase Exception: $e");
        } catch (e) {
          Logger().w("Firebase Exception: $e");
        } finally {
          if (downloadUrl != null) {
            annonceDetails.selectedImages[i] =
                CustomImage(imgType: ImageType.network, path: downloadUrl);
          } else {
            allImagesUpdated = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text("Couldn't upload image ${i + 1} due to some issue"),
              ),
            );
          }
        }
      }
    }
    return allImagesUpdated;
  }

  Future<void> addImageButtonCallback({int index}) async {
    final annonceDetails = Provider.of<AnnonceDetails>(context, listen: false);
    if (index == null && annonceDetails.selectedImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Max 3 images can be uploaded")));
      return;
    }
    String path;
    String snackbarMessage;
    try {
      path = await choseImageFromLocalFiles(context);
      if (path == null) {
        throw LocalImagePickingUnknownReasonFailureException();
      }
    } on LocalFileHandlingException catch (e) {
      Logger().i("Local File Handling Exception: $e");
      snackbarMessage = e.toString();
    } catch (e) {
      Logger().i("Unknown Exception: $e");
      snackbarMessage = e.toString();
    } finally {
      if (snackbarMessage != null) {
        Logger().i(snackbarMessage);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snackbarMessage),
          ),
        );
      }
    }
    if (path == null) {
      return;
    }
    if (index == null) {
      annonceDetails.addNewSelectedImage(
          CustomImage(imgType: ImageType.local, path: path));
    } else {
      annonceDetails.setSelectedImageAtIndex(
          CustomImage(imgType: ImageType.local, path: path), index);
    }
  }
}
