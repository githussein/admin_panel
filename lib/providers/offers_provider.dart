import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'offer.dart';
import '../models/http_exception.dart';

class OffersProvider with ChangeNotifier {
  //A list of pre-loaded offers
  List<Offer> _offersItems = [
    // Offer(
    //     id: "o1",
    //     title: "o1",
    //     imageUrl:
    //         "https://image.shutterstock.com/image-vector/summer-sale-template-banner-vector-260nw-656471581.jpg",
    //     link: "https://islamway.net"),
    // Offer(
    //     id: "o2",
    //     title: "o1",
    //     imageUrl:
    //         "https://cdn3.vectorstock.com/i/1000x1000/93/42/biggest-sale-offers-and-discount-banner-template-vector-14299342.jpg",
    //     link: "https://islamway.net"),
    // Offer(
    //     id: "o3",
    //     title: "o1",
    //     imageUrl:
    //         "https://media.istockphoto.com/vectors/flash-sale-banner-lightning-sales-poster-fast-offer-discount-and-only-vector-id1145641382",
    //     link: "https://islamway.net"),
  ];

  List<Offer> get items {
    return [..._offersItems]; //return a copy not the reference
  }

  Offer findById(String id) {
    return items.firstWhere((offer) => offer.id == id);
  }

  Future<void> addOffer(Offer offer) async {
    //Send data to the server
    final url = Uri.parse(
        'https://wafar-cash-demo-default-rtdb.europe-west1.firebasedatabase.app/offers.json');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': offer.title,
          'imageUrl': offer.imageUrl,
          'link': offer.link,
        }),
      );
      //This will only runs after the previous block
      //It is invisibly wrapped in a "then" block
      final newOffer = Offer(
          //Use the unique id generated by Flutter
          id: json.decode(response.body)['name'], //A unique id from Firebase
          title: offer.title,
          imageUrl: offer.imageUrl,
          link: offer.link);
      //add the offer to the local list on top
      _offersItems.insert(0, newOffer);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateOffer(String id, Offer newOffer) async {
    final url = Uri.parse(
        'https://wafar-cash-demo-default-rtdb.europe-west1.firebasedatabase.app/offers.json');
    final offerIndex = _offersItems.indexWhere((offer) => offer.id == id);

    if (offerIndex >= 0) {
      try {
        await http.patch(url,
            body: json.encode({
              'title': newOffer.title,
              'imageUrl': newOffer.imageUrl,
              'link': newOffer.link,
            }));
      } catch (error) {
        throw error;
      }

      _offersItems[offerIndex] = newOffer;
      notifyListeners();
    }
  }

  Future<void> deleteOffer(String id) async {
    final url = Uri.parse(
        'https://wafar-cash-demo-default-rtdb.europe-west1.firebasedatabase.app/offers/$id.json');

    //perform Optimistic Updating
    final existingOfferIndex =
        _offersItems.indexWhere((offer) => offer.id == id);
    var existingOffer = _offersItems[existingOfferIndex]; //store a copy
    _offersItems.removeAt(existingOfferIndex); //immediately delete
    notifyListeners();

    //Delete on the server and check errors
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _offersItems.insert(existingOfferIndex, existingOffer);
      notifyListeners();
      throw HttpException('Could not delete offer'); //return
    }

    //if no problems occurred
    existingOffer = null; //remove it from memory
  }

  Future<void> fetchOffers() async {
    final url = Uri.parse(
        'https://wafar-cash-demo-default-rtdb.europe-west1.firebasedatabase.app/offers.json');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Offer> loadedOffersList = [];

      extractedData.forEach((offerId, offerData) {
        loadedOffersList.add(Offer(
          id: offerId,
          title: offerData['title'],
          imageUrl: offerData['imageUrl'],
          link: offerData['link'],
        ));
      });
      _offersItems = loadedOffersList;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }
}
