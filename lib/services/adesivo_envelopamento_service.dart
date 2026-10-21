import 'dart:async';
import '../models/adesivo_envelopamento_model.dart';
import 'jsonbin_service.dart';

class AdesivoEnvelopamentoService {
  final JsonBinService _jsonBinService = JsonBinService();

  Future<List<AdesivoEnvelopamento>> listarTodos() async {
    return await _jsonBinService.listarAdesivos();
  }

  Future<AdesivoEnvelopamento?> consultarPorId(String id) async {
    return await _jsonBinService.consultarAdesivoPorId(id);
  }

  Future<void> cadastrar(AdesivoEnvelopamento adesivo) async {
    await _jsonBinService.cadastrarAdesivo(adesivo);
  }

  Future<void> atualizar(AdesivoEnvelopamento adesivo) async {
    await _jsonBinService.atualizarAdesivo(adesivo);
  }

  Future<void> excluir(String id) async {
    await _jsonBinService.excluirAdesivo(id);
  }

  Future<bool> checkSkuExists(String sku, {String? excludeId}) async {
    return await _jsonBinService.checkSkuExistsAdesivo(sku, excludeId: excludeId);
  }

  Stream<List<AdesivoEnvelopamento>> getAdesivosStream({
    String? searchQuery,
    String sortField = 'createdAt',
    bool sortDescending = true,
    bool onlyActive = true,
    bool onlyInactive = false,
  }) {
    final controller = StreamController<List<AdesivoEnvelopamento>>();

    Future<void> fetchAndEmit() async {
      try {
        var adesivos = await listarTodos();

        if (onlyActive) {
          adesivos = adesivos.where((a) => a.ativo).toList();
        } else if (onlyInactive) {
          adesivos = adesivos.where((a) => !a.ativo).toList();
        }

        if (searchQuery != null && searchQuery.isNotEmpty) {
          final lowerQuery = searchQuery.toLowerCase();
          adesivos = adesivos.where((a) {
            return a.nome.toLowerCase().contains(lowerQuery) ||
                a.marca.toLowerCase().contains(lowerQuery) ||
                a.sku.toLowerCase().contains(lowerQuery);
          }).toList();
        }

        adesivos.sort((a, b) {
          int comparison = 0;
          switch (sortField) {
            case 'nome':
              comparison = a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
              break;
            case 'preco':
              comparison = a.preco.compareTo(b.preco);
              break;
            case 'estoque':
              comparison = a.estoque.compareTo(b.estoque);
              break;
            case 'createdAt':
            default:
              comparison = a.createdAt.compareTo(b.createdAt);
              break;
          }
          return sortDescending ? -comparison : comparison;
        });

        if (!controller.isClosed) {
          controller.add(adesivos);
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    }

    fetchAndEmit();
    final timer = Timer.periodic(const Duration(seconds: 30), (_) => fetchAndEmit());

    controller.onCancel = () {
      timer.cancel();
    };

    return controller.stream;
  }
}