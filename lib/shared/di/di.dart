import 'package:d_id_task/data/datasources/video_generator_datasource.dart';
import 'package:d_id_task/data/network/remote_api.dart';
import 'package:d_id_task/presentation/image_to_video/view_model/cubit.dart';
import 'package:d_id_task/repositories/video_generator_repo.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void initDependencies() {
  getIt.registerLazySingleton(() => RemoteApi());
  getIt.registerLazySingleton(() => VideoGeneratorDatasource(getIt<RemoteApi>()));
  getIt.registerLazySingleton(() => VideoGeneratorRepository(getIt<VideoGeneratorDatasource>()));
  getIt.registerFactory(() => ImageToVideoCubit(getIt<VideoGeneratorRepository>()));
}