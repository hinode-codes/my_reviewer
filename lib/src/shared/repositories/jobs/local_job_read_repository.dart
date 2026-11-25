import 'package:my_reviewer/src/shared/db/dao/jobs_dao.dart';
import 'package:my_reviewer/src/shared/db/models/jobs_db_model.dart';
import 'package:my_reviewer/src/shared/models/job_model.dart';

import 'i_job_read_repository.dart';
import 'job_row_mapper.dart';

class LocalJobReadRepository implements IJobReadRepository {
  const LocalJobReadRepository({required this.dao})
    : _mapper = const JobRowMapper();

  final JobDao dao;
  final JobRowMapper _mapper;

  @override
  Future<JobModel?> getById(String id) async =>
      _mapper.maybeModel(await dao.getById(id));

  @override
  Stream<List<JobModel>> watchByGroupKey(String groupKey) {
    return dao.watchByGroupKey(groupKey).map(_mapper.models);
  }

  @override
  Future<JobModel?> getActiveByItemKey(String itemKey) async =>
      _mapper.maybeModel(await dao.getActiveByItemKey(itemKey));

  @override
  Future<List<JobModel>> getByStatus(JobStatus status) async =>
      _mapper.models(await dao.getByStatus(status));

  @override
  Stream<List<JobModel>> watchByStatus(JobStatus status) =>
      dao.watchByStatus(status).map(_mapper.models);

  @override
  Stream<JobModel?> watchLatestByItemKey(String itemKey) =>
      dao.watchLatestByItemKey(itemKey).map(_mapper.maybeModel);

  @override
  Stream<List<JobModel>> watchActiveByGroupKey(String groupKey) =>
      dao.watchActiveByGroupKey(groupKey).map(_mapper.models);

  @override
  Stream<List<JobModel>> watchDeadJobs() => watchByStatus(JobStatus.dead);

  @override
  Stream<DateTime?> watchNextRunAfter() => dao.watchNextRunAfter();

  @override
  Future<DateTime?> getNextRunAfter() => dao.getNextRunAfter();

  @override
  Future<int> countQueued() => dao.countQueued();
}
