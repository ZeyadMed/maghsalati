import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maghsalati/core/bloc/base_bloc.dart';
import 'package:maghsalati/features/profile/data/app_info_data_source.dart';
import 'package:maghsalati/features/profile/data/model/page_content_model.dart';

/// بتجيب محتوى صفحة من [ContentPage] (سياسة الخصوصية، نطاق الخدمة، مقدم الخدمة)
/// وبتحطه في state.data
class PageContentCubit extends Cubit<BaseState<PageContentModel>> {
  final AppInfoDataSource _dataSource;

  PageContentCubit(this._dataSource)
    : super(const BaseState<PageContentModel>());

  Future<void> load(ContentPage page) async {
    emit(state.copyWith(status: Status.loading));

    final result = await _dataSource.getPageContent(page);
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(status: Status.failure, errorMessage: failure.message),
      ),
      (content) => emit(state.copyWith(status: Status.success, data: content)),
    );
  }
}
