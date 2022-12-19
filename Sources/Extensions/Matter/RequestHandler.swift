import HAKit
import MatterSupport
import PromiseKit
import Shared

// The extension is launched in response to `MatterAddDeviceRequest.perform()` and this class is the entry point
// for the extension operations.
class RequestHandler: MatterAddDeviceExtensionRequestHandler {
    override func validateDeviceCredential(
        _ deviceCredential: MatterAddDeviceExtensionRequestHandler.DeviceCredential
    ) async throws {
        // Use this function to perform additional attestation checks if that is useful for your ecosystem.
    }

    override func selectWiFiNetwork(from wifiScanResults: [
        MatterAddDeviceExtensionRequestHandler.WiFiScanResult
    ]) async throws -> MatterAddDeviceExtensionRequestHandler.WiFiNetworkAssociation {
        .defaultSystemNetwork
    }

    override func selectThreadNetwork(from threadScanResults: [
        MatterAddDeviceExtensionRequestHandler.ThreadScanResult
    ]) async throws -> MatterAddDeviceExtensionRequestHandler.ThreadNetworkAssociation {
        .defaultSystemNetwork
    }

    override func commissionDevice(
        in home: MatterAddDeviceRequest.Home?,
        onboardingPayload: String,
        commissioningID: UUID
    ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            when(resolved: Current.apis.map { api in
                api.connection.send(.matterComission(code: onboardingPayload)).promise.map { _ in () }
            }).done { results in
                if results.contains(where: { result in
                    switch result {
                    case .fulfilled: return true
                    case .rejected: return false
                    }
                }) {
                    continuation.resume()
                } else {
                    // TODO:
                    enum SomeError: Error { case error }
                    continuation.resume(with: .failure(SomeError.error))
                }
            }
        }
    }

    override func rooms(in home: MatterAddDeviceRequest.Home?) async -> [MatterAddDeviceRequest.Room] {
        []
    }

    override func configureDevice(named name: String, in room: MatterAddDeviceRequest.Room?) async {
        // Use this function to configure the (now) commissioned device with the given name and room.
    }
}