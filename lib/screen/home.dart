import 'package:flutter/material.dart';
import 'package:flutter_application_8/pokemon_list_response/pokemon_list_response.dart';
import 'package:flutter_application_8/pokemon_list_response/result.dart';
import 'dart:convert';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:http/http.dart' as http;

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  PokemonListScreenState createState() => PokemonListScreenState();
}

class PokemonListScreenState extends State<PokemonListScreen> {
  List<Result>? pokemonList;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPokemonList();
  }

  Future<void> fetchPokemonList() async {
    final response =
        await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/'));

    if (response.statusCode == 200) {
      final pokemonRespose =
          PokemonListResponse.fromMap(json.decode(response.body));
      setState(() {
        pokemonList = pokemonRespose.results;
        isLoading = false;
      });
    } else {
      throw Exception('Failed');
    }
  }

  Future<String> fetchPokemonImageUrl(String pokemonUrl) async {
    final response = await http.get(Uri.parse(pokemonUrl));

    if (response.statusCode == 200) {
      final pokemonData = json.decode(response.body);
      return pokemonData['sprites']['front_default'];
    } else {
      throw Exception('Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokemon List'),
      ),
      body: Skeletonizer(
        enabled: isLoading,
        child: ListView.builder(
            itemCount: pokemonList!.length,
            itemBuilder: (context, index) {
              final pokemon = pokemonList![index];
              return ListTile(
                title: Text(pokemon.name ?? ''),
                leading: FutureBuilder<String>(
                  future: fetchPokemonImageUrl(pokemon.url!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Icon(Icons.error);
                    } else {
                      return Image.network(snapshot.data ?? '');
                    }
                  },
                ),
              );
            }),
      ),
    );
  }
}
