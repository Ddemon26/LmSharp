using LmSharp.Models;
namespace LmSharp;

/// <summary>
///     Factory for creating LmSharp instances with various configurations.
/// </summary>
public static class ClientFactory {
    /// <summary>
    ///     Creates a client with default settings (localhost:1234).
    /// </summary>
    public static ILmSharp Create()
        => new LmSharpClient();

    /// <summary>
    ///     Creates a client with custom base URL.
    /// </summary>
    public static ILmSharp Create(string baseUrl) {
        var settings = new LMSSettings { BaseUrl = baseUrl };
        return new LmSharpClient( settings );
    }

    /// <summary>
    ///     Creates a client with custom base URL and API key.
    /// </summary>
    public static ILmSharp Create(string baseUrl, string apiKey) {
        var settings = new LMSSettings {
            BaseUrl = baseUrl,
            ApiKey = apiKey,
        };
        return new LmSharpClient( settings );
    }

    /// <summary>
    ///     Creates a client with custom settings.
    /// </summary>
    public static ILmSharp Create(LMSSettings settings)
        => new LmSharpClient( settings );

    /// <summary>
    ///     Creates a client using a configuration action.
    /// </summary>
    public static ILmSharp Create(Action<LMSSettings> configure) {
        var settings = new LMSSettings();
        configure( settings );
        return new LmSharpClient( settings );
    }
}