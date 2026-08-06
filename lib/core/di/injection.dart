import 'package:get_it/get_it.dart';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import 'package:bkuhub_mobile/features/ormawa/data/datasources/ormawa_remote_data_source.dart';
import 'package:bkuhub_mobile/features/ormawa/data/repositories/ormawa_repository_impl.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/repositories/ormawa_repository.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/repositories/ormawa_calendar_repository.dart';
import 'package:bkuhub_mobile/features/ormawa/data/repositories/ormawa_calendar_repository_impl.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/usecases/get_ormawa_calendar_usecase.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_calendar_provider.dart';

final sl = GetIt.instance; // sl stands for Service Locator

void setupLocator() {
  // Core
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  // Datasources
  sl.registerLazySingleton<OrmawaRemoteDataSource>(
    () => OrmawaRemoteDataSourceImpl(dio: sl<ApiClient>().client),
  );

  // Repositories
  sl.registerLazySingleton<OrmawaRepository>(
    () => OrmawaRepositoryImpl(ormawaRemoteDataSource: sl()),
  );
  
  sl.registerLazySingleton<OrmawaCalendarRepository>(
    () => OrmawaCalendarRepositoryImpl(remoteDataSource: sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => GetOrmawaCalendarUseCase(sl()));

  // Providers
  sl.registerFactory(() => OrmawaCalendarProvider(sl()));
}
