#ifndef JOURNAL_VOLUME_MANAGER_HPP
#define JOURNAL_VOLUME_MANAGER_HPP

#include <set>
#include <mutex>
#include <condition_variable>
#include <boost/asio.hpp>
#include <boost/noncopyable.hpp>
#include <boost/thread/thread.hpp>
#include "connection.hpp"
#include "journal_writer.hpp"
#include "pre_processor.hpp"
#include "nedmalloc.h"

#define BUFFER_POOL_SIZE 1024*1024*64
#define REQUEST_BODY_SIZE 512

namespace Journal{

class Volume
    :public boost::enable_shared_from_this<Volume>,
     private boost::noncopyable
{
public:
    explicit Volume(boost::asio::io_service& io_service);
    virtual ~Volume();
    JournalWriter& get_writer();
    raw_socket& get_raw_socket();
    void start();
    void stop();
    bool init();
    void set_property(std::string vol_id,std::string vol_path);
private:
    void periodic_task();
    entry_queue write_queue_;
    entry_queue entry_queue_;
    raw_socket raw_socket_;

    std::condition_variable entry_cv;
    std::condition_variable write_cv;
        
    PreProcessor pre_processor;
    Connection connection;
    JournalWriter writer;

    nedalloc::nedpool * buffer_pool;

    std::string vol_id_;
    std::string vol_path_;
};
typedef boost::shared_ptr<Volume> volume_ptr;


class VolumeManager
    :private boost::noncopyable
{
public:
    VolumeManager();
    virtual ~VolumeManager();
    void start(volume_ptr vol);
    void stop(std::string vol_id);
    void stop_all();
    bool init();
    void add_vol(volume_ptr vol);
private:
    void periodic_task();
    void handle_request_header(volume_ptr vol,const boost::system::error_code& e);
    void handle_request_body(volume_ptr vol,const boost::system::error_code& e);
    std::mutex mtx;
    boost::shared_ptr<boost::thread> thread_ptr;
    std::map<std::string,volume_ptr> volumes;
    boost::array<char, HEADER_SIZE> header_buffer_;
    boost::array<char, 512> body_buffer_;

    int_least64_t interval;
    int journal_limit;
};
}

#endif  